/* eslint-disable @typescript-eslint/no-unused-vars */
import { getBranchApiInfo, getBrandApiInfo, getCodeApiInfo, getCustomerApiInfo, getOrderApiInfo, Order, SelectsTypes } from 'apis'
import { z } from 'zod'


export const schemaCreateOrder = z.object({
    branchId: z.string().nonempty(),
    branchName: z.string().nonempty(),
    regionId: z.string().nonempty(),
    regionName: z.string().nonempty(),
    creditLimit: z.number(),
    creditUsed: z.number(),
    productPrice: z.number(),
    transactionLastMonth: z.number(),
    transactionPerMonth: z.number(),
    code: z.string().optional(),
    creator: z.object({
        id: z.string().nonempty(),
        email: z.string().email().nonempty(),
        name: z.string().nonempty(),
        imageUrl: z.string(),
        phone: z.string().nonempty(),
        roles: z.number(),
        note: z.string(),
    }),
    customer: z.object({
        id: z.string().nonempty(),
        name: z.string().nonempty(),
        email: z.string().email().nonempty(),
        phone: z.string().nonempty(),
        imageUrl: z.string(),
        note: z.string().optional(),
        picName: z.string(),
        picPhone: z.string(),
        addressLngLat: z.number().array(),
        addressName: z.string(),
    }),
    deliveryAt: z.string().nonempty(),
    deliveryPrice: z.number(),
    deliveryType: z.number(),
    paymentMethod: z.number(),
    poFilePath: z.string().optional(),
    priceId: z.string().nonempty(),
    priceName: z.string().nonempty(),
    product: z.array(z.object({
        id: z.string().nonempty(),
        categoryId: z.string().nonempty(),
        categoryName: z.string().nonempty(),
        team: z.number(),
        brandId: z.string().nonempty(),
        brandName: z.string().nonempty(),
        salesId: z.string().optional(),
        salesName: z.string().optional(),
        name: z.string().nonempty(),
        description: z.string().optional(),
        size: z.string(),
        imageUrl: z.string(),
        point: z.number(),
        unitPrice: z.number(),
        discount: z.number(),
        qty: z.number(),
        totalPrice: z.number(),
        additional: z.number(),
        tax: z.number(),
    })),
    userApprover: z.array(z.object({
        id: z.string().nonempty(),
        phone: z.string().nonempty(),
        email: z.string().nonempty(),
        name: z.string().nonempty(),
        imageUrl: z.string().nonempty(),
        fcmToken: z.string().nonempty(),
        note: z.string().nonempty(),
        roles: z.number(),
        status: z.number(),
        updatedAt: z.string().nonempty(),
    })).optional()
})

export const codeSearch = () => {
    const search = (v: string) => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const d: SelectsTypes[] = []
            getCodeApiInfo()
                .find({ page: 1, limit: 20 })
                .then((res) => {
                    res.items.forEach((it) => {
                        d.push({
                            label: `${it.id} - ${it.description}`,
                            value: JSON.stringify(it),
                        })
                    })
                    resolve(d)
                })
        })
    }

    return search
}

export const branchSearch = () => {
    const search = (v: string) => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const d: SelectsTypes[] = []
            getBranchApiInfo()
                .find({ page: 1, limit: 10, search: v })
                .then((res) => {
                    res.items.forEach((it) => {
                        d.push({
                            label: it.name,
                            value: it.id,
                        })
                    })
                    resolve(d)
                })
        })
    }

    return search
}

export const brandSearch = () => {
    const search = (v: string) => {
        return new Promise<SelectsTypes[]>((resolve, reject) => {
            const d: SelectsTypes[] = []
            getBrandApiInfo()
                .find()
                .then((res) => {
                    res.forEach((it) => {
                        d.push({
                            label: it.name,
                            value: JSON.stringify(it),
                        })
                    })
                    resolve(d)
                })
        })
    }

    return search
}

export const customerSearchByBranch = (branchId: string) => {
    const search = (v: string) => {
        return new Promise<SelectsTypes[]>((resolve, reject) => {
            const d: SelectsTypes[] = []
            getCustomerApiInfo()
                .findCustomer({ page: 1, limit: 10, branchId, search: v || '' })
                .then((res) => {
                    res.items.forEach((it) => {
                        if (it.business) {
                            d.push({
                                label: it.name,
                                value: JSON.stringify(it),
                            })
                        }
                    })
                    resolve(d)
                })
        })
    }

    return search
}

export const getOrderById = async (req: {
    id: string
    setOrderData: React.Dispatch<React.SetStateAction<Order[]>>
    setLoading: (v: boolean) => void
}) => {
    req.setLoading(true)
    try {
        const result = await getOrderApiInfo().findById(req.id)
        req.setOrderData([result])
    } catch (e) {
        console.log(e)
    } finally {
        req.setLoading(false)
    }
}

/* eslint-disable @typescript-eslint/no-explicit-any */
import { UseToastOptions } from '@chakra-ui/react'
import { UseMutationResult } from '@tanstack/react-query'
import {
    ApproveApply,
    CreateCustomerApply,
    CreateCustomerNoAuth,
    CustomerApply,
    Customers,
    getPriceListApiInfo,
    PriceList,
    SelectsTypes,
    getEmployeeApiInfo,
    Tax,
    CreateNewLimit,
    getBranchApiInfo,
    Branch,
    UpdateBusiness,
    StatusUserApprover,
    Credit,
    Eteam,
} from 'apis'
import { Control, FormState, UseFormGetValues, UseFormRegister, UseFormReset, UseFormSetValue, UseFormWatch } from 'react-hook-form'
import { ZodError, z } from 'zod'

export type ReqTypes = CustomerApply & {
    priceList_?: SelectsTypes
    location_?: SelectsTypes
    roles_?: SelectsTypes
    team_?: SelectsTypes
    note_?: string
    limit_?: string
    _day?: SelectsTypes
    _type?: SelectsTypes
    image_?: File
    customerImage_?: File
    picImage_?: File
    taxImage_?: File
}

export interface setMapsProps {
    idx: number
    type: 'office' | 'shipping'
}

export interface ICustomerCtx {
    register: UseFormRegister<ReqTypes>
    control: Control<ReqTypes>
    setValue: UseFormSetValue<ReqTypes>
    reset: UseFormReset<ReqTypes>
    getValues: UseFormGetValues<ReqTypes>
    formState: FormState<ReqTypes>
    watch: UseFormWatch<ReqTypes>
    isReadOnly: boolean
}

export const searchsPriceList = () => {
    const b = () => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const data: SelectsTypes[] = []
            getPriceListApiInfo()
                .find()
                .then((res) => {
                    res.forEach((i) => {
                        data.push({
                            value: JSON.stringify(i),
                            label: i.name,
                        })
                    })
                    resolve(data)
                })
        })
    }

    return b
}

export const searchsBranch = () => {
    const b = (e: string) => {
        return new Promise<SelectsTypes[]>((resolve) => {
            const data: SelectsTypes[] = []
            getBranchApiInfo()
                .find({ page: 1, limit: 20, search: e })
                .then((res) => {
                    res.items.forEach((i) => {
                        data.push({
                            value: JSON.stringify(i),
                            label: `${i.region.name}, ${i.name}`,
                        })
                    })
                    resolve(data)
                })
        })
    }

    return b
}

interface onCreateI {
    approveApply: UseMutationResult<CustomerApply, Error, ApproveApply, unknown>
    rData: ReqTypes
    isCancel?: boolean
    onClose: () => void
    adminId: string
}

interface ICreateNewLimit {
    note: string
    team: Eteam
    credit: Credit
    roles: number
    priceList: PriceList
    transactionLastMonth: number
    transactionPerMonth: number
}

interface onCreateApplyLimit {
    createApplyNewLimit: UseMutationResult<CustomerApply, Error, CreateNewLimit, unknown>
    rData: ICreateNewLimit
    customers: Customers
    onClose: () => void
    setLoading: (v: boolean) => void
    toast?: ({ description, status, title }: UseToastOptions) => any
    adminId: string
}
const newLimitvalidation = z.object({
    note: z.string(),
    team: z.number(),
    creditProposal: z.object({
        limit: z.number().min(1),
        term: z.number().min(1),
        termInvoice: z.number().min(1),
        used: z.number().min(0),
    }),
    priceList: z.object({
        id: z.string(),
        name: z.string(),
    }),
    transactionLastMonth: z.number(),
    transactionPerMonth: z.number(),
})

export const onCreateNewLimit = async (req: onCreateApplyLimit) => {
    const rData = req.rData
    req.setLoading(true)
    try {
        const findApprover = await getEmployeeApiInfo().findApproverCredit({
            branchId: req.customers.business.location.branchId,
            regionId: req.customers.business.location.regionId,
            team: rData.team,
        })
        const findMe = findApprover.findIndex((i) => i.id === req.adminId)
        findApprover[findMe].status = StatusUserApprover.APPROVE
        findApprover[findMe].note = rData.note || '-'
        findApprover[findMe].updatedAt = new Date().toISOString()

        const ReqData: CreateNewLimit = {
            id: req.customers.id,
            note: rData.note,
            team: rData.team,
            address: req.customers.business.address,
            creditProposal: rData.credit,
            creditActual: req.customers.business.credit,
            customer: {
                address: req.customers.business.customer.address,
                email: req.customers.email,
                idCardNumber: req.customers.business.customer.idCardNumber,
                idCardPath: req.customers.business.customer.idCardPath,
                imageUrl: req.customers.imageUrl,
                name: req.customers.name,
                phone: req.customers.phone,
            },
            location: req.customers.business.location,
            pic: req.customers.business.pic,
            priceList: {
                id: rData.priceList.id,
                name: rData.priceList.name,
            },
            transactionLastMonth: rData.transactionLastMonth,
            transactionPerMonth: rData.transactionPerMonth,
            viewer: req.rData.roles,
            tax: req.customers.business.tax,
            userApprover: findApprover,
        }
        newLimitvalidation.parse(ReqData)
        await req.createApplyNewLimit.mutateAsync(ReqData)
    } catch (error) {
        if (!req.toast) return
        const err = error as Error
        if (err instanceof ZodError) {
            req.toast({
                status: 'error',
                description: 'Input tidak valid',
            })
        }
    } finally {
        req.onClose()
        req.setLoading(false)
    }
}

export const onCreate = async (req: onCreateI) => {
    const rData = req.rData
    const idAdmin = localStorage.getItem('admin-id')
    const team = 0;
    const findApprover =  req.rData.userApprover
    const findMe = findApprover.findIndex((i) => i.id === String(idAdmin))
    findApprover[findMe].status = StatusUserApprover.APPROVE
    findApprover[findMe].note = rData.note_ || '-'
    findApprover[findMe].updatedAt = new Date().toISOString()

    const ReqData: ApproveApply = {
        id: rData.id,
        creditProposal: {
            limit: Number(rData.creditProposal.limit),
            term: Number(rData.creditProposal.term),
            termInvoice: Number(rData.creditProposal.termInvoice),
            used: Number(rData.creditProposal.used),
        },
        note: rData.note_ || '',
        team: rData.team,
        userApprover: findApprover,
        priceList: rData.priceList,

    }
    // console.log(ReqData)
    await req.approveApply.mutateAsync(ReqData)
    req.onClose()
}

interface onCreateApplyI {
    createCustomerApply: UseMutationResult<CustomerApply, Error, CreateCustomerApply, unknown>
    createCustomer: UseMutationResult<Customers, Error, CreateCustomerNoAuth, unknown>
    rData: ReqTypes
    isCancel?: boolean
    onClose: () => void
    roles: number
    toast?: ({ description, status, title }: UseToastOptions) => any
}

interface IUpdateBusiness {
    updateBusiness: UseMutationResult<Customers, Error, UpdateBusiness, unknown>
    roles: number
    rData: ReqTypes
    onClose: () => void
    toast?: ({ description, status, title }: UseToastOptions) => any
}

const createBusinessValidation = z.object({
    address: z.array(
        z.object({
            name: z.string(),
            lngLat: z.number().array(),
        })
    ),
    creditProposal: z.object({
        limit: z.number(),
        term: z.number(),
        termInvoice: z.number(),
        used: z.number(),
    }),
    customer: z.object({
        id: z.string(),
        idCardPath: z.string(),
        idCardNumber: z.string(),
        address: z.string(),
        phone: z.string(),
    }),
    location: z.object({
        branchId: z.string(),
        branchName: z.string(),
        regionId: z.string(),
        regionName: z.string(),
    }),
    pic: z.object({
        idCardPath: z.string(),
        idCardNumber: z.string(),
        name: z.string(),
        phone: z.string(),
        email: z.string(),
        address: z.string(),
    }),
    priceList: z.object({
        id: z.string(),
        name: z.string(),
    }),
    taxData: z
        .object({
            exchangeDay: z.number(),
            legalityPath: z.string(),
            type: z.number(),
        })
        .nullish(),
    transactionLastMonth: z.number(),
    transactionPerMonth: z.number(),
    viewer: z.number(),
})

const updateBusinessValidation = z.object({
    address: z.array(
        z.object({
            name: z.string(),
            lngLat: z.number().array(),
        })
    ),
    location: z.object({
        branchId: z.string(),
        branchName: z.string(),
        regionId: z.string(),
        regionName: z.string(),
    }),
    tax: z
        .object({
            exchangeDay: z.number(),
            legalityPath: z.string(),
            type: z.number(),
        })
        .nullish(),
    viewer: z.number(),
})

export const onUpdateBussiness = async (req: IUpdateBusiness) => {
    try {
        const rData = req.rData
        const branch = JSON.parse(`${rData.location_?.value}`) as Branch
        let taxData: Tax | null = req.rData.tax
        if (req.rData.tax !== null) {
            taxData = {
                exchangeDay: req.rData.tax.exchangeDay,
                legalityPath: req.rData.tax.legalityPath,
                type: req.rData.tax.type,
                image_: req.rData.tax.image_,
            }

            if (rData._type) {
                taxData.type = Number(rData._type.value)
            }

            if (rData._day) {
                taxData.exchangeDay = Number(rData._day.value)
            }
        }

        const checkPhonePic = rData.pic.phone.startsWith('0') ? rData.pic.phone.replace('0', '+62') : rData.pic.phone
        const ReqData: UpdateBusiness = {
            id: rData.id,
            address: [...rData.address],
            location: {
                branchId: branch.id,
                branchName: branch.name,
                regionId: branch.region.id,
                regionName: branch.region.name,
            },
            pic: {
                idCardPath: rData.pic.idCardPath,
                idCardNumber: rData.pic.idCardNumber,
                name: rData.pic.name,
                phone: checkPhonePic,
                email: rData.pic.email,
                address: rData.pic.address,
                image_: rData.pic.image_,
            },
            tax: taxData,
            viewer: Number(req.roles),
        }

        // console.log(ReqData)
        await updateBusinessValidation.parseAsync(ReqData)
        await req.updateBusiness.mutateAsync(ReqData)
        req.onClose()
    } catch (e) {
        if (!req.toast) return
        console.log('eee', e)
        req.toast({
            description: 'Input tidak valid',
            status: 'error',
        })
    }
}

export const onCreateApply = async (req: onCreateApplyI) => {
    try {
        const rData = req.rData
        const prriceList = JSON.parse(`${rData.priceList_?.value}`) as PriceList
        const branch = JSON.parse(`${rData.location_?.value}`) as Branch
        let taxData: Tax | null = null
        taxData = {
            exchangeDay: 0,
            legalityPath: '/private/legality',
            type: 0,
        }

        if (rData._type) {
            taxData.type = Number(rData._type.value)
        }

        if (rData._day) {
            taxData.exchangeDay = Number(rData._day.value)
        }

        const checkPhonePic = rData.pic.phone.startsWith('0') ? rData.pic.phone.replace('0', '+62') : rData.pic.phone
        const checkPhoneCustomer = rData.customer.phone.startsWith('0') ? rData.customer.phone.replace('0', '+62') : rData.customer.phone

        const ReqData: CreateCustomerApply = {
            address: [...rData.address],
            creditProposal: {
                limit: Number(rData.creditProposal.limit),
                term: Number(rData.creditProposal.term),
                termInvoice: Number(rData.creditProposal.termInvoice),
                used: Number(rData.creditProposal.used) || 0,
            },
            customer: {
                id: rData.id,
                idCardPath: rData.customer.idCardPath,
                idCardNumber: rData.customer.idCardNumber,
                address: rData.customer.address,
                image_: rData.customer.image_,
                phone: checkPhoneCustomer,
            },
            location: {
                branchId: branch.id,
                branchName: branch.name,
                regionId: branch.region.id,
                regionName: branch.region.name,
            },
            pic: {
                idCardPath: rData.pic.idCardPath,
                idCardNumber: rData.pic.idCardNumber,
                name: rData.pic.name,
                phone: checkPhonePic,
                email: rData.pic.email,
                address: rData.pic.address,
                image_: rData.pic.image_,
            },
            priceList: {
                id: prriceList.id,
                name: prriceList.name,
            },
            tax: taxData,
            transactionLastMonth: Number(rData.transactionLastMonth || 0),
            transactionPerMonth: Number(rData.transactionPerMonth || 0),
            viewer: Number(req.rData.roles_),
        }

        createBusinessValidation.parse(ReqData)

        await req.createCustomer.mutateAsync({
            email: `${rData.customer.email}`,
            name: `${rData.customer.name}`,
            phone: `${checkPhoneCustomer}`,
            image_: rData.image_,
        })
        await req.createCustomerApply.mutateAsync({
            ...ReqData,
            customer: {
                ...ReqData.customer,
            },
        })

        req.onClose()
    } catch (e) {
        if (!req.toast) return
        req.toast({
            description: 'Input tidak valid',
            status: 'error',
        })
    }
}

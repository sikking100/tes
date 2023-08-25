import { req } from '../../request'
import { Eteam, ProductTypes, ReqPaging, ResPaging } from '../'
import queryString from 'query-string'
import { uploadFile } from '../../storage'

export enum OrderStatus {
    APPLY = 0,
    PENDING = 1,
    COMPLETE = 2,
    CANCEL = 3,
}

export interface Order {
    id: string
    invoiceId: string
    deliveryId: string
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    priceId: string
    priceName: string
    code: string
    customer: CustomerOrder
    creator: CancelOrder
    cancel: CancelOrder
    product: ProductOrder[]
    deliveryPrice: number
    productPrice: number
    totalPrice: number
    poFilePath: string
    status: number
    createdAt: string
    updatedAt: string
}
export interface CreateOrder {
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    priceId: string
    priceName: string
    code: string
    customer: CustomerOrder
    creator: CancelOrder
    cancel: CancelOrder | null
    product: CreateProductOrder[]
    paymentMethod: number
    deliveryType: number
    deliveryPrice: number
    productPrice: number
    totalPrice: number
    deliveryAt: string
    poFilePath: string
    termInvoice: number
    creditLimit: number
    creditUsed: number
    transactionLastMonth: number
    transactionPerMonth: number
    userApprover: UserApproverOrder[]
    pdfFile?: File
}

export interface OrderUser {
    id: string
    name: string
    phone: string
    email: string
    imageUrl: string
    roles: number
    note?: string
}

export interface CustomerOrder {
    id: string
    name: string
    phone: string
    email: string
    imageUrl: string
    picName: string
    picPhone: string
    addressName: string
    addressLngLat: number[]
    note: string
}

export interface CreateProductOrder {
    id: string
    categoryId: string
    categoryName: string
    team: number
    brandId: string
    brandName: string
    salesId: string
    salesName: string
    name: string
    description: string
    size: string
    imageUrl: string
    point: number
    unitPrice: number
    discount: number
    qty: number
    totalPrice: number
    additional?: number
    tax: number
    categoryTeam?: number
    finalPrice_?: number
    countAdditional?: number
}

export interface ProductOrder {
    id: string
    categoryId: string
    categoryName: string
    brandId: string
    brandName: string
    salesId: string
    salesName: string
    name: string
    description: string
    size: string
    imageUrl: string
    point: number
    unitPrice: number
    discount: number
    qty: number
    totalPrice: number
    tax: number
}

export interface CancelOrder extends OrderUser {
    idOrder: string
}

export interface ReqPageOrder extends ReqPaging {
    userid?: string
    regionId?: string
    branchId?: string
    code?: string
    status?: number
}

export interface ReqOrderReport {
    startAt: string
    endAt: string
    query?: string
}

export interface ReqOrderPerformance {
    startAt: string
    endAt: string
    query?: string
    team: Eteam
}

export interface ReportOrder {
    orderId: string
    salesId: string
    salesName: string
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    priceId: string
    priceName: string
    customerId: string
    customerName: string
    productId: string
    productName: string
    productQty: number
    productDiscount: number
    productUnitPrice: number
    productTotalPrice: number
    productPoint: number
    tax: number;
    createdAt: string
}

export interface ReportPerformance {
    regionId: string,
    regionName: string,
    branchId: string,
    branchName: string,
    categoryId: string,
    categoryName: string,
    categoryTarget: number,
    qty: number
}

export interface OrderApply {
    id: string
    userApprover: UserApproverOrder[]
    overLimit: number
    overDue: number
    status: number
    expiredAt: string
}

export interface UserApproverOrder {
    id: string
    phone: string
    email: string
    name: string
    imageUrl: string
    fcmToken: string
    status: number
    note: string
    updatedAt: string
}

export enum StatusOrderApply {
    PENDING = 0,
    WAITING_APPROVE = 1,
    APPROVE = 2,
    REJECT = 3,
}

export enum TypeOrderApply {
    WAITING_APPROVE = 0,
    HISTORY = 1,
}

export interface ReqOrderApply {
    type: TypeOrderApply
}

export interface ApproveOrder {
    idOrder: string
    userId: string
    note: string
    userApprover: UserApproverOrder[]
}
export interface OrderTes {
    totalPrice: number
    product: CreateProductOrder[]
}

export interface ReqTransaction {
    customerId: string
}

export class ProductClassCreate {
    constructor(
        public strata: ProductTypes.PriceList,
        public qty: number = 0
    ) { }

    addQty(): void {
        this.qty++
    }

    decreaseQty(): void {
        if (this.qty > 0) {
            this.qty--
        }
    }

    calculateDiscount(): number {
        let discount = 0

        for (const d of this.strata.discount) {
            if (d.max) {
                if (this.qty >= d.min && this.qty <= d.max) {
                    discount = d.discount
                    break
                }
            }
        }

        return discount
    }

    calculateTotalPrice(): number {
        const discount = this.calculateDiscount()
        const subTotal = this.qty * this.strata.price
        const discountedSubTotal = subTotal - discount
        return discountedSubTotal
    }

    calculateTotalPriceWithAdditionalDiscount(
        additionalDiscount: number
    ): number {
        const totalDiscount = this.calculateDiscount() + additionalDiscount
        const subTotal = this.qty * this.strata.price
        const discountedSubTotal = subTotal - totalDiscount
        return discountedSubTotal
    }

    toCreateProductOrder(): CreateProductOrder {
        const discount = this.calculateDiscount()
        const totalPrice = this.calculateTotalPrice()
        return {
            id: this.strata.id,
            categoryId: '',
            categoryName: '',
            team: 0,
            brandId: '',
            brandName: '',
            salesId: '',
            salesName: '',
            name: '',
            description: '',
            size: '',
            imageUrl: '',
            point: 0,
            unitPrice: this.strata.price,
            discount,
            qty: this.qty,
            totalPrice,
            // additionalDiscount: 0,
            tax: 0,
        }
    }
}

export class Api {
    private static instance: Api
    private constructor() { }
    public static getInstance(): Api {
        if (!Api.instance) {
            Api.instance = new Api()
        }

        return Api.instance
    }
    private path = '/order/v1'
    private pathApply = '/order-apply/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'order tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPageOrder) {
        const qString = queryString.stringify(
            {
                num: r.page,
                limit: r.limit,
                query: [r.userid, r.regionId, r.branchId, r.code, r.status],
            },
            {
                skipEmptyString: true,
                arrayFormat: 'separator',
                arrayFormatSeparator: ',',
            }
        )

        return `${this.path}?${qString}`
    }

    setUrlReport(r: ReqOrderReport) {
        const qString = queryString.stringify(
            {
                startAt: r.startAt,
                endAt: r.endAt,
                query: r.query,
            },
            { skipEmptyString: true }
        )

        return `${this.path}/find/report?${qString}`
    }

    setUrlPerformance(r: ReqOrderPerformance) {
        const qString = queryString.stringify(
            {
                startAt: r.startAt,
                endAt: r.endAt,
                team: r.team,
                query: r.query,
            },
            { skipEmptyString: true }
        )

        return `${this.path}/find/performance?${qString}`
    }

    async findTransactionLastMonth(r: ReqTransaction) {
        const data = await req<number>({
            method: 'GET',
            path: `${this.path}/transaction/last-month?customerId=${r.customerId}`,
            errors: this.errors,
        })
        return data
    }

    async findTransactionPerMonth(r: ReqTransaction) {
        const data = await req<number>({
            method: 'GET',
            path: `${this.path}/transaction/per-month?customerId=${r.customerId}`,
            errors: this.errors,
        })
        return data
    }

    async find(r: ReqPageOrder) {
        const data = await req<ResPaging<Order>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findReport(r: ReqOrderReport) {
        const data = await req<ReportOrder[]>({
            method: 'GET',
            path: this.setUrlReport(r),
            errors: this.errors,
        })
        return data
    }

    async findPerformance(r: ReqOrderPerformance) {
        const data = await req<ReportPerformance[]>({
            method: 'GET',
            path: this.setUrlPerformance(r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string) {
        const data = await req<Order>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateOrder) {
        const fileExt = r.pdfFile?.name.split('.').pop()
        const path = `private/order/${r.customer.id + "-" + Date.now()}/${Date.now()}.${fileExt}`
        if (r.pdfFile) {
            await uploadFile({
                file: r.pdfFile,
                path,
            })
            r.poFilePath = path
        }
        const data = await req<Order>({
            method: 'POST',
            path: this.path,
            body: r,
            errors: this.errors,
        })

        return data
    }

    async cancel(r: CancelOrder) {
        const data = await req<Order>({
            method: 'PUT',
            path: `${this.path}/${r.idOrder}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    /**
     * APPLY
     */

    async findApply(r: ReqOrderApply) {
        const data = await req<OrderApply[]>({
            method: 'GET',
            path: `${this.pathApply}?type=${r.type}`,
            errors: this.errors,
        })
        return data
    }

    async findApplyById(id: string) {
        const data = await req<OrderApply>({
            method: 'GET',
            path: `${this.pathApply}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async approveOrderApply(r: ApproveOrder) {
        const data = await req<OrderApply>({
            method: 'PUT',
            path: `${this.pathApply}/${r.idOrder}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async rejectOrderApply(r: ApproveOrder) {
        const data = await req<OrderApply>({
            method: 'PATCH',
            path: `${this.pathApply}/${r.idOrder}`,
            body: r,
            errors: this.errors,
        })
        return data
    }
}

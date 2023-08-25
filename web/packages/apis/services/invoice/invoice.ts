import { req } from '../../request'
import { ReqPaging, ResPaging } from '../'
import queryString from 'query-string'

export interface InvoiceReport {
    id: string
    transactionId: string
    orderId: string
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    customer: CustomerInvoiceReport
    price: number
    paid: number
    channel: string
    method: string
    destination: string
    paymentMethod: number
    url: string
    status: number
    term: Date
    createdAt: Date
    paidAt: Date
}

export interface CustomerInvoiceReport {
    id: string
    name: string
    phone: string
    email: string
}

export interface Invoice {
    id: string
    transactionId: string
    orderId: string
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    customer: CustomerInvoice
    price: number
    paid: number
    channel: string
    method: string
    destination: string
    paymentMethod: number
    url: string
    status: number
    term: string
    createdAt: string
    paidAt: string
}

export interface CustomerInvoice {
    id: string
    name: string
    phone: string
    email: string
}

export interface CompletePayment {
    id: string
    paid: number
}

export enum typeInvoice {
    WAITINGPAY = 0,
    OVERDUE = 1,
    HISTORY = 2,
}

export enum EPaymentMethod {
    COD = 0,
    TOP = 1,
    TRA = 2,
}

export enum StatusInvoice {
    APPLY = 0,
    PENDING = 1,
    WAITING_PAY = 2,
    PAID = 3,
    CANCEL = 4,
}

export interface ReqPageInvoice extends ReqPaging {
    type?: typeInvoice
    userid?: string
    branchId?: string
    regionId?: string
    paymentMethod?: EPaymentMethod
    orderId?: string
}

export interface ReqReportInvoice {
    startAt: string
    endAt: string
    branchId?: string
    regionId?: string
    paymentMethod?: string
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
    private path = '/invoice/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'invoice tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPageInvoice) {
        const qString = queryString.stringify(
            {
                num: r.page,
                limit: r.limit,
                type: r.type,
                query: [r.userid, r.branchId, r.regionId, r.paymentMethod],
            },
            {
                arrayFormat: 'separator',
                arrayFormatSeparator: ',',
                skipEmptyString: true,
            }
        )
        return `${this.path}?${qString}`
    }

    async find(r: ReqPageInvoice) {
        const data = await req<ResPaging<Invoice>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string) {
        const data = await req<Invoice>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async createPayment(id: string) {
        const data = await req<Invoice>({
            method: 'POST',
            path: `${this.path}/${id}/make-payment`,
            errors: this.errors,
        })
        return data
    }

    async completePayment(r: CompletePayment) {
        const data = await req<Invoice>({
            method: 'POST',
            path: `${this.path}/${r.id}/complete-payment`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async findInvoiceByIdOrder(orderId: string) {
        const data = await req<Invoice[]>({
            method: 'GET',
            path: `${this.path}/${orderId}/by-order`,
            errors: this.errors,
        })
        return data
    }

    async findReportInvoice(r: ReqReportInvoice) {
        const qString = queryString.stringify(
            {
                startAt: r.startAt,
                endAt: r.endAt,
                query: [r.regionId, r.branchId, r.paymentMethod],
            },
            {
                arrayFormat: 'separator',
                arrayFormatSeparator: ',',
                skipEmptyString: true,
            }
        )
        const data = await req<InvoiceReport[]>({
            method: 'GET',
            path: `${this.path}/find/report?${qString}`,
            errors: this.errors,
        })
        return data
    }
}

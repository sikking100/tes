import { ResPaging } from '..'
import {
    Api,
    CompletePayment,
    CustomerInvoice,
    Invoice,
    ReqPageInvoice,
    ReqReportInvoice,
    StatusInvoice,
    typeInvoice,
    EPaymentMethod,
    InvoiceReport,
} from './invoice'
export type {
    CompletePayment,
    CustomerInvoice,
    Invoice,
    ReqPageInvoice,
    ReqReportInvoice,
    InvoiceReport,
}
export { StatusInvoice, EPaymentMethod, typeInvoice }
export interface ApiInvoiceInfo {
    find(r: ReqPageInvoice): Promise<ResPaging<Invoice>>
    findById(id: string): Promise<Invoice>
    createPayment(id: string): Promise<Invoice>
    completePayment(req: CompletePayment): Promise<Invoice>
    findInvoiceByIdOrder(orderId: string): Promise<Invoice[]>
    findReportInvoice(r: ReqReportInvoice): Promise<InvoiceReport[]>
}
export function getInvoiceApiInfo(): ApiInvoiceInfo {
    return Api.getInstance()
}

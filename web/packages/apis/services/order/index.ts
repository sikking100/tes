import { ResPaging } from '..'
import {
    Api,
    ApproveOrder,
    CancelOrder,
    CreateOrder,
    CustomerOrder,
    Order,
    OrderApply,
    OrderUser,
    ProductOrder,
    ReportOrder,
    ReqOrderApply,
    ReqOrderPerformance,
    ReqOrderReport,
    ReqPageOrder,
    UserApproverOrder,
    ProductClassCreate,
    ReqTransaction,
    OrderStatus,
    TypeOrderApply,
    ReportPerformance,
    StatusOrderApply,
} from './order'
export { ProductClassCreate, OrderStatus, TypeOrderApply, StatusOrderApply }
export type {
    ApproveOrder,
    CancelOrder,
    CreateOrder,
    ReportPerformance,
    CustomerOrder,
    Order,
    OrderApply,
    OrderUser,
    ProductOrder,
    ReportOrder,
    ReqOrderApply,
    ReqOrderPerformance,
    ReqOrderReport,
    ReqPageOrder,
    UserApproverOrder,
    ReqTransaction,
}

export interface ApiOrderInfo {
    findTransactionLastMonth(r: ReqTransaction): Promise<number>
    findTransactionPerMonth(r: ReqTransaction): Promise<number>
    find(r: ReqPageOrder): Promise<ResPaging<Order>>
    findReport(r: ReqOrderReport): Promise<ReportOrder[]>
    findPerformance(r: ReqOrderPerformance): Promise<ReportPerformance[]>
    findById(id: string): Promise<Order>
    create(r: CreateOrder): Promise<Order>
    cancel(id: CancelOrder): Promise<Order>

    //  APPLY
    findApply(r: ReqOrderApply): Promise<OrderApply[]>
    findApplyById(id: string): Promise<OrderApply>
    approveOrderApply(r: ApproveOrder): Promise<OrderApply>
    rejectOrderApply(r: ApproveOrder): Promise<OrderApply>
}
export function getOrderApiInfo(): ApiOrderInfo {
    return Api.getInstance()
}

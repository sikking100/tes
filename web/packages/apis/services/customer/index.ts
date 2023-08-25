import { ResPaging } from '..'
import {
    Api,
    ApproveApply,
    ApproveBranch,
    ApproveLimit,
    Business,
    CreateCustomerApply,
    CreateNewLimit,
    Credit,
    CreditProposal,
    Customer,
    CustomerApply,
    Customers,
    Pic,
    Reject,
    ReqCustomerApplyGet,
    ReqCustomerGet,
    Tax,
    UpdateBusiness,
    UserApprover,
    CreateCustomerNoAuth,
    TypeCustomerApply,
    StatusUserApprover,
    TypeApply, RejectApply, StatusCustomerApply
} from './customers'
export type {
    ApproveApply,
    RejectApply,
    ApproveBranch,
    ApproveLimit,
    Business,
    CreateCustomerApply,
    CreateNewLimit,
    Credit,
    CreditProposal,
    Customer,
    CustomerApply,
    Customers,
    Pic,
    Reject,
    ReqCustomerApplyGet,
    ReqCustomerGet,
    Tax,
    UpdateBusiness,
    CreateCustomerNoAuth,
    UserApprover,
}

export interface ApiCustomerInfo {
    findCustomerApply(
        req: ReqCustomerApplyGet
    ): Promise<ResPaging<CustomerApply>>
    findCustomer(req: ReqCustomerGet): Promise<ResPaging<Customers>>
    findCustomerById(id: string): Promise<Customers>
    findCustomerApplyById(id: string): Promise<CustomerApply>
    updateBusiness(data: UpdateBusiness): Promise<Customers>
    createCustomerApply(data: CreateCustomerApply): Promise<CustomerApply>
    createCustomer(data: CreateCustomerNoAuth): Promise<Customers>
    createApplyNewLimit(data: CreateNewLimit): Promise<CustomerApply>
    approveLimit(data: ApproveLimit): Promise<CustomerApply>
    approveApply(data: ApproveApply): Promise<CustomerApply>
    approveBusiness(data: ApproveBranch): Promise<CustomerApply>
    reject(data: RejectApply): Promise<CustomerApply>
}
export function getCustomerApiInfo(): ApiCustomerInfo {
    return Api.getInstance()
}

export { TypeCustomerApply, StatusUserApprover, TypeApply, StatusCustomerApply }

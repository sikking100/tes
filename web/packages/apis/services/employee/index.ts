import { ResPaging } from '../'
import {
    Api,
    CreateEmployee,
    Employee,
    EmployeeApprover,
    ReqEmployeeApprover,
    UpdateAccountEmployee,
    ReqPagingEmployee,
    Location,
    ECategory,
    Eroles,
} from './employee'
export type {
    CreateEmployee,
    Employee,
    ECategory,
    EmployeeApprover,
    ReqEmployeeApprover,
    UpdateAccountEmployee,
    Location,
    ReqPagingEmployee,
}
export { Eroles }
export interface ApiEmployeeInfo {
    find(r: ReqPagingEmployee): Promise<ResPaging<Employee>>
    findById(r: string): Promise<Employee>
    create(r: CreateEmployee): Promise<Employee>
    update(r: UpdateAccountEmployee): Promise<Employee>
    delete(r: string): Promise<Employee>

    findApproverTOP(r: ReqEmployeeApprover): Promise<EmployeeApprover[]>
    findApproverCredit(r: ReqEmployeeApprover): Promise<EmployeeApprover[]>
}
export function getEmployeeApiInfo(): ApiEmployeeInfo {
    return Api.getInstance()
}

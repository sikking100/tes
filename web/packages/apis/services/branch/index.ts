import { ResPaging } from '../'
import {
    Api,
    Address,
    Branch,
    ReqBranchGet,
    CreateBranch,
    Warehouse,
    CreateWarehouse,
    WarehouseModel,
} from './branch'
export type {
    Address,
    Branch,
    ReqBranchGet,
    CreateWarehouse,
    CreateBranch,
    Warehouse,
    WarehouseModel,
}
export interface ApiBranchInfo {
    find(r: ReqBranchGet): Promise<ResPaging<Branch>>
    findById(r: string): Promise<Branch>
    create(r: CreateBranch): Promise<Branch>
    delete(r: string): Promise<Branch>
    createWarehouse(r: CreateWarehouse[], idBranch: string): Promise<Branch>
    updateWarehouse(r: Warehouse[], branchId: string): Promise<Branch>
    getWarehouseByBranch(branchId: string): Promise<WarehouseModel[]>
}
export function getBranchApiInfo(): ApiBranchInfo {
    return Api.getInstance()
}

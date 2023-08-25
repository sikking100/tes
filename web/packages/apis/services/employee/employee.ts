import { req } from '../../request'
import { Eteam, ReqPaging, ResPaging, SelectsTypes } from './..'
import queryString from 'query-string'
import { uploadFile } from '../../storage'

export interface ReqPagingEmployee extends ReqPaging {
    query?: string
}

export enum Eroles {
    CUSTOMER = 0,
    SYSTEM_ADMIN = 1,
    FINANCE_ADMIN = 2,
    SALES_ADMIN = 3,
    WAREHOUSE_ADMIN = 4,
    BRANCH_ADMIN = 5,
    BRANCH_FINANCE_ADMIN = 6,
    BRANCH_SALES_ADMIN = 7,
    BRANCH_WAREHOUSE_ADMIN = 8,
    DIREKTUR = 9,
    GENERAL_MANAGER = 10,
    NASIONAL_SALES_MANAGER = 11,
    REGIONAL_MANAGER = 12,
    AREA_MANAGER = 13,
    SALES = 14,
    COURIER = 15,
}

export interface ReqSalesByCategory {
    branchId?: string
    categoryId?: string
}

export interface ECategory {
    id: string
    name: string
}

export interface Employee {
    id: string
    phone: string
    email: string
    name: string
    imageUrl: string
    roles: number
    location: Location
    team: number
    fcmToken: string
    createdAt: string
    updatedAt: string
}

export interface Location {
    id: string
    name: string
    type: number
}

export interface CreateEmployee {
    id: string
    phone: string
    email: string
    name: string
    roles: number
    location: Location | null
    team: number
    image_?: File
    team_?: SelectsTypes
    roles_?: SelectsTypes
}

export interface UpdateAccountEmployee {
    id: string
    phone: string
    email: string
    name: string
    image_?: File
}
export interface ReqEmployeeApprover {
    team: Eteam
    branchId: string
    regionId: string
    type?: 'BUSINESS LIMIT' | 'ORDER'
}

export interface EmployeeApprover {
    id: string
    phone: string
    email: string
    name: string
    imageUrl: string
    fcmToken: string
    note: string
    roles: number
    status: number
    updatedAt: string
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
    private path = '/user-employee/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'employee tidak ditemukan',
        409: 'data sudah ada',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPagingEmployee) {
        const queryStr = queryString.stringify(
            { search: r.search, query: r.query },
            { skipEmptyString: true, skipNull: true }
        )
        return `${this.path}?num=${r.page}&limit=${r.limit}&${queryStr}`
    }

    setUrlBySales(r: ReqSalesByCategory) {
        const queryStr = queryString.stringify(
            { categoryId: r.categoryId, branchId: r.branchId },
            { skipEmptyString: true, skipNull: true }
        )
        return `${this.path}/find/sales-category?${queryStr}`
    }

    async find(r: ReqPagingEmployee): Promise<ResPaging<Employee>> {
        const data = await req<ResPaging<Employee>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findSalesByCategory(r: ReqSalesByCategory): Promise<Employee[]> {
        const data = await req<Employee[]>({
            method: 'GET',
            path: this.setUrlBySales(r),
            errors: this.errors,
        })
        return data
    }

    async findById(r: string): Promise<Employee> {
        const data = await req<Employee>({
            method: 'GET',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateEmployee): Promise<Employee> {
        if (r.phone.startsWith('0')) r.phone = r.phone.replace('0', '+62')
        delete r.roles_
        delete r.team_

        const res = await req<Employee>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `employee/${res.id}/${Date.now()}`,
            })
        }

        return res
    }

    async update(r: UpdateAccountEmployee): Promise<Employee> {
        if (r.phone.startsWith('0')) r.phone = r.phone.replace('0', '+62')
        const res = await req<Employee>({
            method: 'PUT',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `employee/${res.id}/${Date.now()}`,
            })
        }

        return res
    }

    async delete(r: string): Promise<Employee> {
        const res = await req<Employee>({
            method: 'DELETE',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return res
    }

    /**
     *
     * FIND EMPLOYEE APPROVER
     *
     */

    async findApproverTOP(r: ReqEmployeeApprover): Promise<EmployeeApprover[]> {
        const queryStr = queryString.stringify({
            regionId: r.regionId,
            branchId: r.branchId,
            team: r.team,
        })
        const data = await req<EmployeeApprover[]>({
            method: 'GET',
            path: `${this.path}/approver/top?${queryStr}`,
            errors: this.errors,
        })
        return data
    }

    async findApproverCredit(
        r: ReqEmployeeApprover
    ): Promise<EmployeeApprover[]> {
        const queryStr = queryString.stringify({
            regionId: r.regionId,
            branchId: r.branchId,
            team: r.team,
        })
        const data = await req<EmployeeApprover[]>({
            method: 'GET',
            path: `${this.path}/approver/credit?${queryStr}`,
            errors: this.errors,
        })
        return data
    }
}

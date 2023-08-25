import { req } from '../../request'
import { ReqPaging, ResPaging } from '../'
import queryString from 'query-string'
import { uploadFile } from '../../storage'

export interface ReqCustomerGet extends ReqPaging {
    viewer?: number
    regionId?: string
    branchId?: string
}

export enum TypeCustomerApply {
    ALL = 0,
    WAITING_LIMIT = 1,
    WAITING_APPROVE = 2,
    WAITING_CREATE = 3,
}

export enum StatusCustomerApply {
    PENDING = 0,
    WAITING_APPROVE = 1,
    APPROVE = 2,
    REJECT = 3,
}

export enum StatusUserApprover {
    PENDING = 0,
    WAITING_APPROVE = 1,
    APPROVE = 2,
    REJECT = 3,
}

export enum TypeApply {
    NEW_BUSINESS = 1,
    NEW_LIMIT = 2,
}

export interface ReqCustomerApplyGet extends ReqPaging {
    userId: string
    type?: TypeCustomerApply
}

export interface UpdateBusiness {
    id: string
    location: Location
    pic: Pic
    address: Address[]
    viewer: number
    tax: Tax
}

export interface Customers {
    id: string
    phone: string
    email: string
    name: string
    imageUrl: string
    business: Business
    createdAt: string
    updatedAt: string
}

export interface CreateCustomer {
    id: string
    idCardPath: string
    idCardNumber: string
    address: string
    email?: string
    name?: string
    phone: string
    image_?: File
    imageUrl?: string
}


export interface CreateCustomerApply {
    location: Location
    priceList: PriceList
    customer: CreateCustomer
    pic: Pic
    address: Address[]
    viewer: number
    creditProposal: CreditProposal
    tax?: Tax | null
    transactionLastMonth: number
    transactionPerMonth: number
    image_?: File
}

export interface CustomerApply {
    id: string
    location: Location
    priceList: PriceList
    customer: Customer
    pic: Omit<Customer, 'imageUrl'>
    address: Address[]
    viewer: number
    creditProposal: Credit
    creditActual: Credit
    tax: Tax
    transactionLastMonth: number
    transactionPerMonth: number
    userApprover: UserApprover[]
    type: number
    status: number
    team: number,
    expiredAt: string
}

export interface Business {
    location: Location
    priceList: PriceList
    customer: Customer
    pic: Pic
    address: Address[]
    viewer: number
    credit: Credit
    tax: Tax
}

interface Address {
    name: string
    lngLat: number[]
}

export interface Credit {
    limit: number
    term: number
    termInvoice: number
    used: number
}

export interface Customer {
    idCardPath: string
    idCardNumber: string
    name: string
    phone: string
    email: string
    address: string
    imageUrl: string
    image_?: File
}

interface Location {
    regionId: string
    regionName: string
    branchId: string
    branchName: string
}

export interface Pic {
    idCardPath: string
    idCardNumber: string
    name: string
    phone: string
    email: string
    address: string
    image_?: File
}

interface PriceList {
    id: string
    name: string
}

export interface Tax {
    exchangeDay: number
    legalityPath: string
    type: number
    image_?: File
}

export interface UserApprover {
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

export interface CreditProposal {
    limit: number
    term: number
    termInvoice: number
    used: number
}

export interface CreateNewLimit
    extends Omit<CustomerApply, 'type' | 'status' | 'expiredAt'> {
    note: string
    team: number
}

export interface ApproveLimit {
    id: string
    team: number
    note: string
    creditProposal: CreditProposal
}

export type ApproveApply = {
    id: string
    note: string
    team: number
    priceList: PriceList
    creditProposal: CreditProposal
    userApprover: UserApprover[]
}

export type RejectApply = Omit<ApproveApply, "creditProposal" | 'priceList' | "team">

export interface CreateCustomerNoAuth {
    phone: string
    email: string
    name: string
    image_?: File
}

export interface ApproveBranch {
    applyId: string
    newId: string
    note: string
}

export type Reject = Omit<ApproveBranch, 'newId'>

export class Api {
    private static instance: Api
    private constructor() { }
    public static getInstance(): Api {
        if (!Api.instance) {
            Api.instance = new Api()
        }

        return Api.instance
    }
    private pathCus = '/user-customer/v1'
    private pathCusApply = '/user-customer-apply/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'customer tidak ditemukan',
        409: 'data sudah digunakan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrlCustomer(r: ReqCustomerGet) {
        const query = queryString.stringify(
            {
                limit: r.limit,
                num: r.page,
                query: [r.viewer, r.regionId, r.branchId],
                search: r.search,
            },
            {
                skipEmptyString: true,
                arrayFormat: 'separator',
                arrayFormatSeparator: ',',
                skipNull: true,
            }
        )

        return `${this.pathCus}?${query}`
    }

    setUrlCustomerApply(r: ReqCustomerApplyGet) {
        const query = queryString.stringify(
            {
                limit: r.limit,
                num: r.page,
                userId: r.userId,
                type: r.type,
            },
            {
                skipEmptyString: true,
            }
        )

        return `${this.pathCusApply}?${query}`
    }

    async findCustomerApply(r: ReqCustomerApplyGet) {
        const data = await req<ResPaging<CustomerApply>>({
            method: 'GET',
            path: this.setUrlCustomerApply(r),
            errors: this.errors,
        })
        return data
    }

    async findCustomer(r: ReqCustomerGet): Promise<ResPaging<Customers>> {
        const data = await req<ResPaging<Customers>>({
            method: 'GET',
            path: this.setUrlCustomer(r),
            errors: this.errors,
        })
        return data
    }

    async findCustomerById(id: string): Promise<Customers> {
        const data = await req<Customers>({
            method: 'GET',
            path: `${this.pathCus}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async findCustomerApplyById(id: string): Promise<CustomerApply> {
        const data = await req<CustomerApply>({
            method: 'GET',
            path: `${this.pathCusApply}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async updateBusiness(r: UpdateBusiness) {
        const pathCusPic = `private/customer/${r.id}/${Date.now() + Math.floor(Math.random() * 1000)
            }.png`
        const pathCusTax = `private/customer/${r.id}/${Date.now() + Math.floor(Math.random() * 1000)
            }.png`
        if (r.pic.image_) {
            await uploadFile({
                file: r.pic.image_,
                path: pathCusPic,
            })
            r.pic.idCardPath = pathCusPic
        }
        if (r.tax?.image_) {
            await uploadFile({
                file: r.tax?.image_,
                path: pathCusTax,
            })
            r.tax.legalityPath = pathCusTax
        }

        delete r.pic.image_
        delete r.tax.image_

        const data = await req<Customers>({
            method: 'PATCH',
            path: `${this.pathCus}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async createCustomer(r: CreateCustomerNoAuth) {
        if (r.phone.startsWith('0')) r.phone.replace('0', '+62')
        const res = await req<Customers>({
            method: 'POST',
            path: `${this.pathCus}`,
            body: r,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `customer/${res.id}/${res.id}`,
            })
        }
        return res
    }

    async createCustomerApply(r: CreateCustomerApply) {
        const pathCusKtp = `private/customer/${r.customer.id}/${Date.now() + Math.floor(Math.random() * 1000)
            }.png`
        const pathCusPic = `private/customer/${r.customer.id}/${Date.now() + Math.floor(Math.random() * 1000)
            }.png`
        const pathCusTax = `private/customer/${r.customer.id}/${Date.now() + Math.floor(Math.random() * 1000)
            }.png`
        if (r.customer.image_) {
            await uploadFile({
                file: r.customer.image_,
                path: pathCusKtp,
            })
            r.customer.idCardPath = pathCusKtp
        }
        if (r.pic.image_) {
            await uploadFile({
                file: r.pic.image_,
                path: pathCusPic,
            })
            r.pic.idCardPath = pathCusPic
        }
        if (r.tax?.image_) {
            await uploadFile({
                file: r.tax?.image_,
                path: pathCusTax,
            })
            r.tax.legalityPath = pathCusTax
        }

        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `customer/${r.customer.id}/${r.customer.id}`,
            })
        }

        delete r.customer.image_
        delete r.pic.image_
        delete r.tax?.image_

        if (r.customer.phone.startsWith('0')) r.customer.phone.replace('0', '+62')
        if (r.pic.phone.startsWith('0')) r.pic.phone.replace('0', '+62')

        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}/new-business`,
            body: r,
            errors: this.errors,
        })

        return data
    }

    async createApplyNewLimit(r: CreateNewLimit) {
        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}/new-limit`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async approveLimit(r: ApproveLimit) {
        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}/approve-limit`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async approveApply(r: ApproveApply) {
        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}/approve`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async approveBusiness(r: ApproveBranch) {
        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}`,
            body: r,
            errors: this.errors,
        })
        return data
    }

    async reject(r: RejectApply) {
        const data = await req<CustomerApply>({
            method: 'POST',
            path: `${this.pathCusApply}/reject`,
            body: r,
            errors: this.errors,
        })
        return data
    }
}

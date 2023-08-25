import { ReqPaging, ResPaging } from '../'
import { req } from '../../request'
import { Region } from '../region'
import queryString from 'query-string'

export interface Branch {
    id: string
    region: Region
    name: string
    address: Address
    warehouse: Warehouse[]
    createdAt: string
    updatedAt: string
}

export interface CreateBranch {
    id: string
    regionId: string
    regionName: string
    name: string
    address: string
    addressLat: number
    addressLng: number
}

export interface CreateWarehouse {
    id: string
    name: string
    phone: string
    address: string
    addressLat: number
    addressLng: number
    isDefault: boolean
}
export interface Warehouse {
    id: string
    name: string
    phone: string
    address: Address
    isDefault: boolean
}

export interface Address {
    name: string
    lngLat: number[]
}

export interface ReqBranchGet extends ReqPaging {
    regionId?: string
}

interface MyObject {
    [key: string]: any
}

export class WarehouseModel implements Warehouse {
    id: string
    name: string
    phone: string
    address: Address
    isDefault: boolean
    constructor(data: Warehouse) {
        this.id = data.id
        this.name = data.name
        this.phone = data.phone
        this.address = data.address
        this.isDefault = data.isDefault
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
    private path = '/location-branch/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'cabang tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqBranchGet) {
        const qString = queryString.stringify(
            { regionId: r.regionId, search: r.search },
            { skipEmptyString: true, skipNull: true }
        )
        let url = `${this.path}?num=${r.page}&limit=${r.limit}&${qString}`
        return url
    }

    async find(r: ReqBranchGet): Promise<ResPaging<Branch>> {
        const data = await req<ResPaging<Branch>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<Branch> {
        const data = await req<Branch>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateBranch): Promise<Branch> {
        const nData: Omit<CreateBranch, 'id'> = {
            regionId: r.regionId,
            regionName: r.regionName,
            name: r.name,
            address: r.address,
            addressLat: r.addressLat,
            addressLng: r.addressLng,
        }

        const res = await req<Branch>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: nData,
            errors: this.errors,
        })
        return res
    }

    async delete(r: string): Promise<Branch> {
        const res = await req<Branch>({
            method: 'DELETE',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return res
    }

    async createWarehouse(
        r: CreateWarehouse[],
        idBranch: string
    ): Promise<Branch> {
        const nData: CreateWarehouse[] = [...r]
        let hasDuplicateId = false
        const seenIds: MyObject = {}
        for (const item of nData) {
            if (seenIds[item.id]) {
                hasDuplicateId = true
                break
            }
            seenIds[item.id] = true
        }

        if (hasDuplicateId) {
            throw new Error('ID tidak boleh sama')
        }

        const mData: CreateWarehouse[] = nData.map((it) => {
            const phone = it.phone.startsWith('0') ? it.phone.replace('0', '+62') : it.phone
            return {
                ...it,
                phone,
            }
        })

        const res = await req<Branch>({
            method: 'PUT',
            body: mData,
            path: `${this.path}/${idBranch}`,
            errors: this.errors,
        })
        return res
    }

    async updateWarehouse(r: Warehouse[], branchId: string): Promise<Branch> {
        const nData: Warehouse[] = r.map((it) => {
            const phone = it.phone.startsWith('0') ? it.phone.replace('0', '+62') : it.phone
            return {
                ...it,
                phone,
            }
        })

        const res = await req<Branch>({
            method: 'PUT',
            path: `${this.path}/${branchId}`,
            errors: this.errors,
            body: nData,
        })
        return res
    }

    async getWarehouseByBranch(branchId: string): Promise<WarehouseModel[]> {
        const res: WarehouseModel[] = []
        const branch = await this.findById(branchId)

        for await (const item of branch.warehouse) {
            res.push(new WarehouseModel(item))
        }
        return res
    }
}

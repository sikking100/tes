import queryString from 'query-string'
import { ReqPaging, ResPaging } from '../'
import { req } from '../../request'

export interface Region {
    id: string
    name: string
    createdAt: string
    updatedAt: string
}

export interface CreateRegion {
    name: string
    id: string
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
    private path = '/location-region/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'region tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPaging) {
        let url = `${this.path}?num=${r.page}&limit=${r.limit}`
        if (r.search) url += `${url}&search=${r.search}`
        return url
    }

    async find(r: ReqPaging): Promise<ResPaging<Region>> {
        const qString = queryString.stringify(
            {
                num: r.page,
                limit: r.limit,
                search: r.search,
            },
            {
                skipEmptyString: true,
                skipNull: true,
            }
        )
        const data = await req<ResPaging<Region>>({
            method: 'GET',
            path: `${this.path}?${qString}`,
            errors: this.errors,
        })
        return data
    }

    async findById(r: string): Promise<Region> {
        const data = await req<Region>({
            method: 'GET',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateRegion): Promise<Region> {
        const res = await req<Region>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async delete(r: string): Promise<Region> {
        const res = await req<Region>({
            method: 'DELETE',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })

        return res
    }
}

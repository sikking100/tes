import { req } from '../../request'

export interface PriceList {
    id: string
    name: string
    createdAt: string
    updatedAt: string
}

export interface CreatePriceList {
    id: string
    name: string
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
    private path = '/product-pricelist/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'price list tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(): Promise<PriceList[]> {
        const data = await req<PriceList[]>({
            method: 'GET',
            path: `${this.path}`,
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<PriceList> {
        const data = await req<PriceList>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreatePriceList): Promise<PriceList> {
        const res = await req<PriceList>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async delete(id: string): Promise<PriceList> {
        const res = await req<PriceList>({
            method: 'DELETE',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return res
    }
}

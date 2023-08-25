import { ReqPaging, ResPaging } from '..'
import { req } from '../../request'

export interface Code {
    id: string
    description: string
    createdAt: string
    updatedAt: string
}

export interface CreateCode {
    description: string
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
    private path = '/code/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'code tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(r: ReqPaging): Promise<ResPaging<Code>> {
        const data = await req<ResPaging<Code>>({
            method: 'GET',
            path: `${this.path}?limit=${r.limit}&num=${r.page}`,
            errors: this.errors,
        })
        return data
    }

    async findById(r: string): Promise<Code> {
        const data = await req<Code>({
            method: 'GET',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: Code): Promise<Code> {
        const res = await req<Code>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async delete(r: string): Promise<Code> {
        const res = await req<Code>({
            method: 'DELETE',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })

        return res
    }
}

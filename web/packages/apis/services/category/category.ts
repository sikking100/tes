import { req } from '../../request'

export interface Category {
    id: string
    name: string
    team: number
    target: number
    createdAt: string
    updatedAt: string
}

export interface CreateCategory {
    id: string
    name: string
    team: number
    target: number
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
    private path = '/category/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'category tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(): Promise<Category[]> {
        const data = await req<Category[]>({
            method: 'GET',
            path: this.path,
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<Category> {
        const data = await req<Category>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateCategory): Promise<Category> {
        const rData: Omit<CreateCategory, 'id'> = {
            name: r.name,
            target: r.target,
            team: r.team,
        }

        const res = await req<Category>({
            method: 'POST',
            path: `${this.path}/${r.id}`,
            body: rData,
            errors: this.errors,
        })
        return res
    }

    async delete(id: string): Promise<Category> {
        const res = await req<Category>({
            method: 'DELETE',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return res
    }
}

import { req } from '../../request'
import { uploadFile } from '../../storage'

export interface Brand {
    id: string
    name: string
    imageUrl: string
    createdAt: string
    updatedAt: string
}

export interface CreateBrand {
    id: string
    name: string
    image_?: File
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
    private path = '/brand/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'brand tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(): Promise<Brand[]> {
        const data = await req<Brand[]>({
            method: 'GET',
            path: this.path,
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<Brand> {
        const data = await req<Brand>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateBrand): Promise<Brand> {
        const rData: Omit<CreateBrand, 'id'> = {
            name: r.name,
        }
        const data = await req<Brand>({
            method: 'POST',
            path: this.path + `/${r.id}`,
            body: rData,
            errors: this.errors,
        })

        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `brand/${data.id}/${Date.now()}`,
            })
        }

        return data
    }

    async delete(id: string): Promise<Brand> {
        const data = await req<Brand>({
            method: 'DELETE',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }
}

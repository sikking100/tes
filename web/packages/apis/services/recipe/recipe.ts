import { req } from '../../request'
import { ReqPaging, ResPaging } from '../'
import { uploadFile } from '../../storage'

export interface ReqPagingRecipe extends ReqPaging {
    category?: string
}

export interface Recipe {
    id: string
    category: string
    title: string
    imageUrl: string
    description: string
    createdAt: string
    updatedAt: string
    image_?: File
}

export interface CreateRecipe {
    category: string
    title: string
    description: string
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
    private path = '/recipe/v1/recipe'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'resep tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPagingRecipe) {
        let url = `${this.path}?num=${r.page}&limit=${r.limit}`
        if (r.category) url += `&category=${r.category}`
        if (r.search) url += `&search=${r.search}`
        return url
    }

    async find(r: ReqPagingRecipe): Promise<ResPaging<Recipe>> {
        const data = await req<ResPaging<Recipe>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<Recipe> {
        const data = await req<Recipe>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateRecipe): Promise<Recipe> {
        const res = await req<Recipe>({
            method: 'POST',
            path: `${this.path}`,
            body: r,
            errors: this.errors,
        })

        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `recipe/${res.id}/${res.id}`,
            })
        }

        return res
    }

    async update(r: Recipe): Promise<Recipe> {
        const res = await req<Recipe>({
            method: 'PUT',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })

        if (r.image_) {
            await uploadFile({
                file: r.image_,
                path: `recipe/${res.id}/${res.id}`,
            })
        }

        return res
    }

    async delete(id: string): Promise<Recipe> {
        const res = await req<Recipe>({
            method: 'DELETE',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })

        return res
    }
}

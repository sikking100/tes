import { req } from '../../request'
import { uploadFile } from '../../storage'

export enum BannerType {
    INTERNAL = 1,
    EXTERNAL = 2,
}
export interface Banner {
    id: string
    type: BannerType
    imageUrl: string
    createdAt: string
    getType(): string
}
class BannerModel implements Banner {
    id: string
    type: BannerType
    imageUrl: string
    createdAt: string
    getType(): string {
        return this.type === BannerType.INTERNAL ? 'internal' : 'external'
    }
    constructor(data: Banner) {
        this.id = data.id
        this.type = data.type
        this.imageUrl = data.imageUrl
        this.createdAt = data.createdAt
    }
}
export interface CreateBanner {
    file: File
    type: BannerType
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
    private path = '/banner/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'banner tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(type: BannerType): Promise<Banner[]> {
        const data = await req<Banner[]>({
            method: 'GET',
            path: `${this.path}?type=${type === BannerType.INTERNAL ? 1 : 2}`,
            errors: this.errors,
        })
        return data
    }
    async create({ file, type }: CreateBanner): Promise<void> {
        const fileName = `${type === BannerType.INTERNAL ? 'internal' : 'external'
            }`
        await uploadFile({
            file,
            path: `banner/${fileName}-${Date.now()}`,
            metadata: { type: String(type) },
        })
    }
    async deleteById(id: string): Promise<Banner> {
        const data = await req<Banner>({
            method: 'DELETE',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return new BannerModel(data)
    }
}

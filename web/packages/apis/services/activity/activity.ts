import { ReqPaging, ResPaging } from '../'
import { req } from '../../request'
import { uploadFile } from '../../storage'

export interface Activity {
    id: string
    title: string
    description: string
    videoUrl: string
    imageUrl: string
    comment: Comment[]
    commentCount: number
    creator: Creator
    createdAt: string
    updatedAt: string
}

export interface Comment {
    id: string
    activityId: string
    comment: string
    creator: Creator
    createdAt: string
}

export interface Creator {
    id: string
    name: string
    roles: number
    imageUrl: string
    description: string
}

export interface CreateActivity extends Omit<Activity, 'id'> {
    image_?: File
}

export interface UpdateActivity extends Activity {
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
    private path = '/activity/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        403: 'forbidden',
        404: 'activity tidak ditemukan',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async find(r: ReqPaging): Promise<ResPaging<Activity>> {
        const data = await req<ResPaging<Activity>>({
            method: 'GET',
            path: `${this.path}?num=${r.page}&limit=${r.limit}`,
            errors: this.errors,
        })
        return data
    }

    async findById(r: string): Promise<Activity> {
        const data = await req<Activity>({
            method: 'GET',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
        return data
    }

    async create(r: CreateActivity): Promise<void> {
        const res = await req<Activity>({
            method: 'POST',
            path: `${this.path}`,
            body: r,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_!,
                path: `activity/${res.id}/${res.id}`,
            })
        }
    }

    async update(r: UpdateActivity): Promise<void> {
        await req({
            method: 'PUT',
            path: `${this.path}/${r.id}`,
            body: r,
            errors: this.errors,
        })
        if (r.image_) {
            await uploadFile({
                file: r.image_!,
                path: `activity/${r.id}`,
            })
        }
    }

    async delete(r: string): Promise<void> {
        await req({
            method: 'DELETE',
            path: `${this.path}/${r}`,
            errors: this.errors,
        })
    }
}

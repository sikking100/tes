import { ReqPaging, ResPaging } from '..'
import { req } from '../../request'
import queryString from 'query-string'

export interface ReqPagingHelp extends ReqPaging {
    isAnswered?: boolean
    userId?: string
    isHelp?: boolean
}

export interface Help {
    id: string
    topic: string
    question: string
    answer: string
    creator: CreatorHelp
    createdAt: string
    updatedAt: string
}

export interface CreatorHelp {
    id: string
    name: string
    roles: number
    imageUrl: string
    description: string
}

export type CreateHelp = Omit<Help, 'id' | 'createdAt' | 'updatedAt'>
export type CreateQuestion = Omit<
    Help,
    'id' | 'createdAt' | 'updatedAt' | 'topic' | 'answer'
>

export class Api {
    private static instance: Api
    private constructor() { }
    public static getInstance(): Api {
        if (!Api.instance) {
            Api.instance = new Api()
        }

        return Api.instance
    }
    private path = '/help/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'help tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrl(r: ReqPagingHelp) {
        const qString = queryString.stringify(
            {
                search: r.search,
                isAnswered: r.isAnswered,
                userId: r.userId,
                isHelp: r.isHelp,
            },
            {
                skipEmptyString: true,
                skipNull: true,
            }
        )
        return `${this.path}/help?num=${r.page}&limit=${r.limit}&${qString}`
    }

    async find(r: ReqPagingHelp): Promise<ResPaging<Help>> {
        const data = await req<ResPaging<Help>>({
            method: 'GET',
            path: this.setUrl(r),
            errors: this.errors,
        })
        return data
    }

    async findById(id: string): Promise<Help> {
        const data = await req<Help>({
            method: 'GET',
            path: `${this.path}/help/${id}`,
            errors: this.errors,
        })
        return data
    }

    async createHelp(r: CreateHelp): Promise<Help> {
        const res = await req<Help>({
            method: 'POST',
            path: `${this.path}/help`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async createQuestion(r: CreateQuestion): Promise<Help> {
        const res = await req<Help>({
            method: 'POST',
            path: `${this.path}/question`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async updateHelp(r: Help): Promise<Help> {
        const res = await req<Help>({
            method: 'POST',
            path: `${this.path}/help/${r.id}`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async updateQuestion(r: Help): Promise<Help> {
        const res = await req<Help>({
            method: 'PUT',
            path: `${this.path}/question/${r.id}`,
            body: r,
            errors: this.errors,
        })

        return res
    }

    async delete(id: string): Promise<Help> {
        const res = await req<Help>({
            method: 'DELETE',
            path: `${this.path}/help/${id}`,
            errors: this.errors,
        })

        return res
    }
}

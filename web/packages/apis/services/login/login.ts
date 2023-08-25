import { FbAuth } from '../../firebase'
import { req } from '../../request'

export interface ReqLogin {
    app: number
    fcmToken: string
    phone: string
}

export interface ReqLoginVerify {
    id: string
    otp: string
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
    private path = '/user-auth/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        403: 'forbidden',
        404: 'user tidak ditemukan',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    async login(r: ReqLogin): Promise<string> {
        const res = await req<string>({
            isNoAuth: true,
            method: 'POST',
            path: `${this.path}`,
            body: r,
            errors: this.errors,
        })
        console.log('in service', res)
        return res
    }

    async loginVerify(r: ReqLoginVerify): Promise<void> {
        const res = await req<string>({
            isNoAuth: true,
            method: 'PUT',
            path: this.path,
            body: r,
            errors: this.errors,
        })

        await FbAuth.signInWithCustomToken(res)
    }
}

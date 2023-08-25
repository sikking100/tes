import { getAuth } from 'firebase/auth'
import { FbApp } from '../firebase'

interface Treq {
    method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'PATCH'
    path: string
    errors: { [key: number]: string }
    body?: any
    isNoAuth?: boolean
}
interface TRes<T> {
    code: number
    errors: string | null
    data: T | null
}
export async function req<R>({
    isNoAuth,
    method,
    path,
    body,
    errors,
}: Treq): Promise<R> {
    let token = ''
    if (!isNoAuth) {
        const user = getAuth(FbApp).currentUser
        if (user === null) {
            throw new Error('current user not found')
        }
        token = await user.getIdToken()
    }

    const baseUrl =
        process.env.NODE_ENV === 'production'
            ? 'https://apigateway-service-l2bago5gdq-et.a.run.app'
            : 'https://apigateway-service-ckndvuglva-et.a.run.app'

    const mReq = await fetch(baseUrl + path, {
        method: method,
        body:
            method === 'GET' || method === 'DELETE' || body === undefined
                ? undefined
                : JSON.stringify(body),
        mode: 'cors',
        headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
            'Content-Type': 'application/json',
        },
    })

    const data: TRes<R> = await mReq.json()
    if (
        data.code >= 200 &&
        data.code <= 299 &&
        // data.errors === null &&
        data.data !== null
    ) {
        return data.data
    } else if (errors[data.code] !== '') {
        throw new Error(errors[data.code])
    } else {
        throw new Error(`unknown error ${data.code}: ${data.errors}`)
    }
}

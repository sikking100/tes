import { Api, ReqLogin, ReqLoginVerify } from './login'
export type { ReqLogin, ReqLoginVerify }
export interface ApiLoginInfo {
    login(r: ReqLogin): Promise<string>
    loginVerify(r: ReqLoginVerify): Promise<void>
}
export function getLoginApiInfo(): ApiLoginInfo {
    return Api.getInstance()
}

import { ReqPaging, ResPaging } from '..'
import { Api, Code, CreateCode } from './code'
export type { Code, CreateCode }
export interface ApiCodeInfo {
    find(req: ReqPaging): Promise<ResPaging<Code>>
    findById(r: string): Promise<Code>
    create(r: CreateCode): Promise<Code>
    delete(r: string): Promise<Code>
}
export function getCodeApiInfo(): ApiCodeInfo {
    return Api.getInstance()
}

import { ResPaging } from '../'
import {
    Api,
    CreateHelp,
    CreateQuestion,
    CreatorHelp,
    Help,
    ReqPagingHelp,
} from './help'
export type { CreateHelp, CreateQuestion, CreatorHelp, Help, ReqPagingHelp }
export interface ApiHelpInfo {
    find(r: ReqPagingHelp): Promise<ResPaging<Help>>
    findById(r: string): Promise<Help>
    createHelp(r: CreateHelp): Promise<Help>
    createQuestion(r: CreateQuestion): Promise<Help>
    updateHelp(r: Help): Promise<Help>
    updateQuestion(r: Help): Promise<Help>
    delete(r: string): Promise<Help>
}
export function getHelpApiInfo(): ApiHelpInfo {
    return Api.getInstance()
}

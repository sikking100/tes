import { ReqPaging, ResPaging } from '../'
import {
    Api,
    Activity,
    Creator,
    CreateActivity,
    UpdateActivity,
} from './activity'
export type { Activity, Creator, CreateActivity, UpdateActivity }
export interface ApiActivityInfo {
    find(r: ReqPaging): Promise<ResPaging<Activity>>
    findById(r: string): Promise<Activity>
    create(r: CreateActivity): Promise<void>
    update(r: UpdateActivity): Promise<void>
    delete(r: string): Promise<void>
}
export function getActivityApiInfo(): ApiActivityInfo {
    return Api.getInstance()
}

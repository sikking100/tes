import { ResPaging } from '../'
import {
    Api,
    ActionPackingList,
    CompletePackingList,
    Courier,
    CourierType,
    CreatePackingList,
    ReqDeliveryPrice,
    CustomerDelivery,
    Delivery,
    PackingListWarehousue,
    ProductDelivery,
    ReqFindDelivery,
    ReqFindProductByStatus,
    ReqPackingList,
    SetCourierExternal,
    SetInternalCourier,
    UpdateQty,
    WarehouseDelivery,
    StatusDelivery,
    ReqPackingListCourier,
    ReqPackingListDestination,
    PackingListDestination,
    PackingListCourier,
    TypeReqDelivery,
    ReqFindProductByStatusDelivery,
    ActionPackingListRestock,
} from './delivery'
export type {
    ActionPackingList,
    CompletePackingList,
    Courier,
    CreatePackingList,
    ReqDeliveryPrice,
    CustomerDelivery,
    Delivery,
    PackingListWarehousue,
    ProductDelivery,
    ReqFindDelivery,
    ReqFindProductByStatus,
    ReqPackingList,
    SetCourierExternal,
    SetInternalCourier,
    UpdateQty,
    WarehouseDelivery,
    ReqPackingListCourier,
    ReqPackingListDestination,
    PackingListDestination,
    PackingListCourier,
    ReqFindProductByStatusDelivery,
    ActionPackingListRestock,
}

export { TypeReqDelivery, StatusDelivery, CourierType }
export interface ApiDeliveryInfo {
    find(r: ReqFindDelivery): Promise<ResPaging<Delivery>>
    findById(id: string): Promise<Delivery>
    findByOrder(idOrder: string): Promise<Delivery[]>
    createPackingList(r: CreatePackingList): Promise<Delivery>
    setCourierInternal(r: SetInternalCourier): Promise<Delivery>
    setCourierExternal(r: SetCourierExternal): Promise<Delivery>
    updateQty(r: UpdateQty): Promise<Delivery>
    loadedPackingList(r: ActionPackingList): Promise<Delivery>
    restockPackingList(r: ActionPackingListRestock): Promise<Delivery>
    completePackingList(r: CompletePackingList): Promise<Delivery>
    findPackingListWarehouse(
        r: ReqPackingList
    ): Promise<PackingListWarehousue[]>
    findPackingListCourier(
        r: ReqPackingListCourier
    ): Promise<PackingListCourier[]>
    findPackingListDestination(
        r: ReqPackingListDestination
    ): Promise<PackingListDestination[]>
    findProductByStatus(r: ReqFindProductByStatus): Promise<ProductDelivery[]>
    getDeliveryPrice(r: ReqDeliveryPrice): Promise<number>
    getProductByStatus(
        r: ReqFindProductByStatusDelivery
    ): Promise<ProductDelivery[]>
}
export function getDeliveryApiInfo(): ApiDeliveryInfo {
    return Api.getInstance()
}

import { req } from '../../request'
import { ReqPaging, ResPaging } from './..'
import queryString from 'query-string'
import { uploadFile } from '../../storage'
import { fbFirestore } from '../../firebase'

export interface Delivery {
    id: string
    orderId: string
    regionId: string
    regionName: string
    branchId: string
    branchName: string
    customer: CustomerDelivery
    courier: Courier
    courierType: number
    url: string
    product: ProductDelivery[]
    note: string
    status: number
    deliveryAt: string
    createdAt: string
}

export interface Courier {
    id: string
    name: string
    phone: string
    imageUrl: string
}

export interface CustomerDelivery {
    id: string
    name: string
    phone: string
    picName: string
    picPhone: string
    addressName: string
    addressLngLat: number[]
}

export interface ProductDelivery {
    id: string
    warehouse: WarehouseDelivery | null
    category: string
    brand: string
    name: string
    size: string
    imageUrl: string
    purcaseQty: number
    deliveryQty: number
    reciveQty: number
    brokenQty: number
    status: number
}

export interface WarehouseDelivery {
    id: string
    name: string
    addressName: string
    addressLngLat: number[]
}

export enum CourierType {
    INTERNAL = 0,
    EXTERNAL = 1,
}

export interface CreatePackingList {
    id: string
    courierType: number
    product: ProductDelivery[]
}

export interface SetInternalCourier {
    deliveryId: string
    id: string
    name: string
    phone: string
    imageUrl: string
}

export interface SetCourierExternal {
    id: string
    customer: CustomerDelivery
    customerPicName: string
    customerPicPhone: string
    customerAddressName: string
    customerAddressLng: number
    customerAddressLat: number
    warehousePicName: string
    warehousePicPhone: string
    warehouseAddressName: string
    warehouseAddressLng: number
    warehouseAddressLat: number
    item: string
}

export interface UpdateQty {
    id: string
    productId: string
    deliveryQty: number
}

export interface ActionPackingList {
    id: string
    branchId: string
    warehouseId: string
    productId: string
    productDeliveryQty: number
    courierId: string
}

export interface ActionPackingListRestock {
    id: string
    warehouseId: string
    branchId: string
    // product: ProductDelivery[]
    // status: StatusDelivery
    // brokenQty: {
    //     [key: string]: number
    // }
}

export interface CompletePackingList {
    id: string
    courierId: string
    product: ProductDelivery[]
}

export interface PackingListWarehousue {
    courier: Courier
    product: ProductDelivery[]
}

export interface PackingListDestination {
    orderId: string
    deliveryId: string
    customer: {
        id: string
        name: string
        phone: string
        picName: string
        picPhone: string
        addressName: string
        addressLngLat: number[]
    }
}

export interface PackingListCourier {
    warehouse: {
        id: string
        name: string
        addressName: string
        addressLngLat: number[]
    }
    product: ProductDelivery[]
}

export enum TypeReqDelivery {
    APPLY = 'APPLY',
    PENDING = 'PENDING',
    CREATE_PACKING_LIST = 'CREATE PACKING LIST',
    ADD_COURIER = 'ADD COURIER',
    PICKED_UP = 'PICKED_UP',
    LOADED = 'LOADED',
    WAITING_DELIVER = 'WAITING DELIVER',
    DELIVER = 'DELIVER',
    RESTOCK = 'RESTOCK',
    COMPLETE = 'COMPLETE',
    CANCEL = 'CANCEL',
}

export interface ReqFindDelivery extends ReqPaging {
    branchId: string
    courierId?: string
    status: StatusDelivery
    orderId?: string
}

export interface ReqPackingList {
    branchId: string
    warehouseId: string
    status: StatusDelivery
}

export interface ReqPackingListCourier {
    courierId: string
    status: StatusDelivery
}

export interface ReqPackingListDestination {
    courierId: string
}

export interface ReqFindProductByStatus {
    courierId: string
    status?: StatusDelivery
    warehouseId?: string
}

export interface ReqDeliveryPrice {
    originLat: number
    originLng: number
    destinationLat: number
    destinationLng: number
}

export enum StatusDelivery {
    APPLY = 0,
    PENDING = 1,
    CREATE_PACKING_LIST = 2,
    ADD_COURIER = 3,
    PICKED_UP = 4,
    LOADED = 5,
    WAITING_DELIVER = 6,
    DELIVER = 7,
    RESTOCK = 8,
    COMPLETE = 9,
    CANCEL = 10,
}

export interface ReqFindProductByStatusDelivery {
    courierId: string
    status: StatusDelivery
    warehouseId: string
    branchId: string
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
    private path = '/delivery/v1'
    private errors: { [key: number]: string } = {
        400: 'input tidak valid',
        401: 'hak akses ditolak',
        404: 'delivery tidak ditemukan',
        403: 'forbidden',
        500: 'server sedang bermasalah, silahkan coba beberapa saat lagi',
    }

    setUrlDelivery(r: ReqFindDelivery) {
        const queryStr = queryString.stringify(
            {
                num: r.page,
                limit: r.limit,
                branchId: r.branchId,
                courierId: r.courierId,
                status: r.status,
            },
            { skipEmptyString: true, skipNull: true }
        )
        return `${this.path}?num=${r.page}&limit=${r.limit}&${queryStr}`
    }

    async find(r: ReqFindDelivery) {
        const res = await req<ResPaging<Delivery>>({
            method: 'GET',
            path: this.setUrlDelivery(r),
            errors: this.errors,
        })

        return res
    }

    async findById(id: string) {
        const res = await req<Delivery>({
            method: 'GET',
            path: `${this.path}/${id}`,
            errors: this.errors,
        })
        return res
    }

    async findByOrder(idOrder: string) {
        const res = await req<Delivery[]>({
            method: 'GET',
            path: `${this.path}/${idOrder}/by-order`,
            errors: this.errors,
        })
        return res
    }

    async createPackingList(r: CreatePackingList) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/packing-list`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async setCourierInternal(r: SetInternalCourier) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.deliveryId}/courier-internal`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async setCourierExternal(r: SetCourierExternal) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/courier-external`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async updateQty(r: UpdateQty) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/update-qty`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async loadedPackingList(r: ActionPackingList) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/loaded`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async restockPackingList(r: ActionPackingListRestock) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/restock`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    async completePackingList(r: CompletePackingList) {
        const res = await req<Delivery>({
            method: 'PUT',
            path: `${this.path}/${r.id}/complete`,
            body: r,
            errors: this.errors,
        })
        return res
    }

    setUrlFindPackingList(r: ReqPackingList, path: string) {
        const queryStr = queryString.stringify(
            {
                branchId: r.branchId,
                warehouseId: r.warehouseId,
                status: r.status,
            },
            { skipEmptyString: true, skipNull: true }
        )
        return `${this.path}/paking-list/${path}?${queryStr}`
    }

    async findPackingListWarehouse(r: ReqPackingList) {
        const res = await req<PackingListWarehousue[]>({
            method: 'GET',
            path: this.setUrlFindPackingList(r, 'warehouse'),
            errors: this.errors,
        })
        return res
    }

    async findPackingListCourier(r: ReqPackingListCourier) {
        const queryStr = queryString.stringify(
            {
                courierId: r.courierId,
                status: r.status,
            },
            { skipEmptyString: true, skipNull: true }
        )
        const res = await req<PackingListCourier[]>({
            method: 'GET',
            path: `${this.path}/paking-list/courier?${queryStr}`,
            errors: this.errors,
        })
        return res
    }

    async findPackingListDestination(r: ReqPackingListDestination) {
        const queryStr = queryString.stringify(
            {
                courierId: r.courierId,
            },
            { skipEmptyString: true, skipNull: true }
        )
        const res = await req<PackingListDestination[]>({
            method: 'GET',
            path: `${this.path}/paking-list/destination?${queryStr}`,
            errors: this.errors,
        })
        return res
    }

    setUrlFindProductStatus(r: ReqFindProductByStatus) {
        const queryStr = queryString.stringify(
            {
                courierId: r.courierId,
                status: r.status,
                warehouseId: r.warehouseId,
            },
            { skipEmptyString: true, skipNull: true }
        )
        return `${this.path}/product/find?${queryStr}`
    }

    async findProductByStatus(r: ReqFindProductByStatus) {
        const res = await req<ProductDelivery[]>({
            method: 'GET',
            path: this.setUrlFindProductStatus(r),
            errors: this.errors,
        })
        return res
    }

    async getDeliveryPrice(r: ReqDeliveryPrice) {
        const queryStr = queryString.stringify(
            {
                originLat: r.originLat,
                originLng: r.originLng,
                destinationLat: r.destinationLat,
                destinationLng: r.destinationLng,
            },
            { skipEmptyString: true, skipNull: true }
        )

        const res = await req<number>({
            method: 'GET',
            path: `${this.path}/gosend/price?${queryStr}`,
            errors: this.errors,
        })
        return res
    }

    async getProductByStatus(r: ReqFindProductByStatusDelivery) {
        const queryStr = queryString.stringify(
            {
                courierId: r.courierId,
                status: r.status,
                warehouseId: r.warehouseId,
                branchId: r.branchId,
            },
            { skipEmptyString: true, skipNull: true }
        )

        console.log('queryStr', queryStr)
        console.log('r', r)

        const res = await req<ProductDelivery[]>({
            method: 'GET',
            path: `${this.path}/product/find?${queryStr}`,
            errors: this.errors,
        })
        return res
    }



}

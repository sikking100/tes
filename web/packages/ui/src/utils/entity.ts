import {
    StatusDelivery,
    type SelectsTypes,
    EPaymentMethod,
    Eroles,
    TypeApply,
    StatusInvoice,
    OrderStatus,
    StatusCustomerApply,
    CourierType,
} from 'apis'

export enum Roles {
    CUSTOMER = 'PELANGGAN',
    SYSTEM_ADMIN = 'SYSTEM ADMIN',
    BRANCH_ADMIN = 'BRANCH ADMIN',
    FINANCE_ADMIN = 'FINANCE ADMIN',
    BRANCH_FINANCE_ADMIN = 'BRANCH FINANCE ADMIN',
    SALES_ADMIN = 'SALES ADMIN',
    BRANCH_SALES_ADMIN = 'BRANCH SALES ADMIN',
    WAREHOUSE_ADMIN = 'WAREHOUSE ADMIN',
    DIREKTUR = 'DIREKTUR',
    GENERAL_MANAGER = 'GENERAL MANAGER',
    NSM = 'NASIONAL SALES MANAGER',
    RM = 'REGIONAL MANAGER',
    AM = 'AREA MANAGER',
    SALES = 'SALES',
    COURIER = 'COURIER',
}

export enum RolesEntity {
    CUSTOMER = '0',
    SYSTEM_ADMIN = '1',
    FINANCE_ADMIN = '2',
    SALES_ADMIN = '3',
    BRANCH_ADMIN = '5',
    BRANCH_FINANCE_ADMIN = '6',
    BRANCH_SALES_ADMIN = '7',
    WAREHOUSE_ADMIN = '8',
    DIREKTUR = '9',
    GENERAL_MANAGER = '10',
    NSM = '11',
    RM = '12',
    AM = '13',
    SALES = '14',
    COURIER = '15',
}

export enum Team {
    DEFAULT = '0',
    FOOD_SERVICE = '1',
    RETAIL = '2',
}

export const roles = (key: number): string => {
    let roles = ''

    switch (key) {
        case Eroles.CUSTOMER:
            roles = Roles.CUSTOMER
            break
        case Eroles.SYSTEM_ADMIN:
            roles = Roles.SYSTEM_ADMIN
            break
        case Eroles.FINANCE_ADMIN:
            roles = Roles.FINANCE_ADMIN
            break
        case Eroles.SALES_ADMIN:
            roles = Roles.SALES_ADMIN
            break
        case Eroles.BRANCH_ADMIN:
            roles = Roles.BRANCH_ADMIN
            break
        case Eroles.BRANCH_FINANCE_ADMIN:
            roles = Roles.BRANCH_FINANCE_ADMIN
            break
        case Eroles.BRANCH_SALES_ADMIN:
            roles = Roles.BRANCH_SALES_ADMIN
            break
        case Eroles.BRANCH_WAREHOUSE_ADMIN:
            roles = Roles.WAREHOUSE_ADMIN
            break
        case Eroles.DIREKTUR:
            roles = Roles.DIREKTUR
            break
        case Eroles.GENERAL_MANAGER:
            roles = Roles.GENERAL_MANAGER
            break
        case Eroles.NASIONAL_SALES_MANAGER:
            roles = Roles.NSM
            break
        case Eroles.REGIONAL_MANAGER:
            roles = Roles.RM
            break
        case Eroles.AREA_MANAGER:
            roles = Roles.AM
            break
        case Eroles.SALES:
            roles = Roles.SALES
            break
        case Eroles.COURIER:
            roles = Roles.COURIER
            break
        default:
            roles = ''
            break
    }

    return roles
}

export const team = (prefix: string): string => {
    let team = ''

    switch (prefix) {
        case '0':
            team = 'WALK-IN'
            break
        case '1':
            team = 'FOOD SERVICE'
            break
        case '2':
            team = 'RETAIL'
            break

        default:
            break
    }

    return team
}

export const status = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case 0:
            status = 'PENDING'
            break
        case 1:
            status = 'DISETUJUI'
            break
        case 2:
            status = 'DITOLAK'
            break
        case 3:
            status = 'MENUNGGU PERSETUJUAN'
            break
        default:
            break
    }

    return status
}

export const statusApply = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case 0:
            status = 'PENDING'
            break
        case 1:
            status = 'MENUNGGU PERSETUJUAN'
            break
        case 2:
            status = 'DISETUJUI'
            break
        case 3:
            status = 'DITOLAK'
            break
        default:
            break
    }

    return status
}

export const typeApply = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case TypeApply.NEW_BUSINESS:
            status = 'BISNIS'
            break
        case TypeApply.NEW_LIMIT:
            status = 'LIMIT'
            break
        default:
            break
    }

    return status
}

export const statusOrder = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case OrderStatus.APPLY:
            status = 'MENUNGGU PERSETUJUAN'
            break
        case OrderStatus.PENDING:
            status = 'PENDING'
            break
        case OrderStatus.COMPLETE:
            status = 'SELESAI'
            break
        case OrderStatus.CANCEL:
            status = 'BATAL'
            break
        default:
            break
    }

    return status
}

export const paymentMethod = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case EPaymentMethod.COD:
            status = 'COD'
            break
        case EPaymentMethod.TOP:
            status = 'TOP'
            break
        case EPaymentMethod.TRA:
            status = 'TRANSFER'
            break
        default:
            break
    }

    return status
}

export const statusInvoice = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case StatusInvoice.APPLY:
            status = 'MENUNGGU PERSETUJUAN'
            break
        case StatusInvoice.PENDING:
            status = 'INVOICE PENDING'
            break
        case StatusInvoice.WAITING_PAY:
            status = 'MENUNGGU PEMBAYARAN INVOICE'
            break
        case StatusInvoice.PAID:
            status = 'INVOICE TERBAYAR'
            break
        case StatusInvoice.CANCEL:
            status = 'INVOICE BATAL'
            break
        default:
            break
    }

    return status
}

export const statusDeliver = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case StatusDelivery.APPLY:
            status = 'MENUNGGU PERSETUJUAN'
            break
        case StatusDelivery.PENDING:
            status = 'PENDING'
            break
        case StatusDelivery.CREATE_PACKING_LIST:
            status = 'MENUNGGU DIPROSES'
            break
        case StatusDelivery.ADD_COURIER:
            status = 'MENUNGGU KURIR DTAMBAHKAN'
            break
        case StatusDelivery.PICKED_UP:
            status = 'MENUNGGU DIMUAT'
            break
        case StatusDelivery.LOADED:
            status = 'BARANG DIMUAT'
            break
        case StatusDelivery.WAITING_DELIVER:
            status = 'MENUNGGU DIANTAR'
            break
        case StatusDelivery.DELIVER:
            status = 'BARANG DIANTAR'
            break
        case StatusDelivery.RESTOCK:
            status = 'BARANG RETUR'
            break
        case StatusDelivery.COMPLETE:
            status = 'PENGANTARAN SELESAI'
            break
        case StatusDelivery.CANCEL:
            status = 'PENGANTARAN BATAL'
            break
        default:
            break
    }

    return status
}

export const statusOrderApply = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case 0:
            status = 'PENDING'
            break
        case 1:
            status = 'MENUNGGU PERSETUJUAN'
            break
        case 2:
            status = 'DISETUJUI'
            break
        case 3:
            status = 'DITOLAK'
            break
        default:
            break
    }

    return status
}

export const statusTax = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case 0:
            status = 'NON PKP'
            break
        case 1:
            status = 'PKP'
            break
        default:
            break
    }

    return status
}

export const statusTaxDay = (prefix: number): string => {
    let status = `${prefix}`

    switch (prefix) {
        case 0:
            status = 'MINGGU'
            break
        case 1:
            status = 'SENIN'
            break
        case 2:
            status = 'SELASA'
            break
        case 3:
            status = 'RABU'
            break
        case 4:
            status = 'KAMIS'
            break
        case 5:
            status = 'JUMAT'
            break
        case 6:
            status = 'SABTU'
            break
        default:
            break
    }

    return status
}

export const statusTypeCourier = (prefix: number): string => {
    let status = ''

    switch (prefix) {
        case CourierType.INTERNAL:
            status = 'INTERNAL'
            break
        case CourierType.EXTERNAL:
            status = 'GOSEND'
            break
        default:
            status = '-'
            break
    }

    return status
}

export const checkStatusCustomerApply = (req: { status: number; type: number }) => {
    if (req.type === TypeApply.NEW_LIMIT) {
        return statusApply(req.status)
    }
    if (req.type === TypeApply.NEW_BUSINESS) {
        if (req.status === StatusCustomerApply.APPROVE) {
            return 'MENUNGGU ID'
        }
        return statusApply(req.status)
    }
    return ''
}

export const timeDelivery: SelectsTypes[] = [
    {
        value: '08:00 AM',
        label: 'Pagi (Sebelum jam 12 siang)',
    },
    {
        value: '12:00 PM',
        label: 'Siang (Jam 12:00 - 16:00)',
    },
    {
        value: '04:00 PM',
        label: 'Sore (Diatas jam 16:00)',
    },
]

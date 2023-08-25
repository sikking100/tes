import type { Types } from 'ui'

/**
 * List Item Sidebar Menu Account
 */
export const dataListAccount: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/account',
        title: 'Akun',
    },
]
/**
 * List Item Sidebar Menu account courier
 */

export const dataListCourier: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/account-courier',
        title: 'Kurir',
    },
]
/**
 * List Item Sidebar Menu Profile
 */

export const dataListProfile: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/profile',
        title: 'Kelola Akun',
    },
    {
        id: 2,
        link: '/question',
        title: 'Riwayat Pertanyaan',
    },
    {
        id: 3,
        link: '/help',
        title: 'Pusat Bantuan',
    },
]

/**
 * List Item Sidebar Menu Warehouse
 */

export const dataListWarehouse: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/warehouse',
        title: 'Gudang',
    },
]

/**
 * List Item Sidebar Menu Product
 */
export const dataListProduct: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/product',
        title: 'Produk',
    },
    {
        id: 2,
        link: '/qty-history',
        title: 'Riwayat Stok',
    },
]

/**
 * List Item Sidebar Menu order
 *
 */
export const dataListOrder: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/order',
        title: 'Pesanan',
    },
    {
        id: 2,
        link: '/delivery-packinglist',
        title: 'Packing List',
    },
]

export const dataListDelivery: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/order/delivery-pending',
        title: 'Buat Pengantaran',
    },
    {
        id: 2,
        link: '/order/delivery-in-pickup',
        title: 'Pengantaran',
    },
    {
        id: 3,
        link: '/delivery-complete',
        title: 'Selesai',
    },
]

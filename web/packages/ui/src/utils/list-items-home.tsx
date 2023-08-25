import React from 'react'
import {
    AccountIcons,
    BannerIcons,
    CameraIcons,
    CodeIcons,
    IconPickMaps,
    HomeIcons,
    ProductIcons,
    OrderIcons,
    IconShop,
    UserIcons,
    PencilIcons,
    Receivables,
    BookIcon,
    CustomerIcon,
    BigDataIcon,
    ClipboardList,
    IconMap2,
    TagIcons,
} from '../icons'
import { TbMap2 } from 'react-icons/tb'
import { ListItemProps } from '../types'

export const ListItemHomeSystemAdmin: ListItemProps[] = [
    {
        id: 1,
        icon: <AccountIcons fontSize={25} color={'#1FB5EB'} />,
        color: '#1FB5EB',
        link: '/account',
        text: 'Akun',
    },
    {
        id: 2,
        icon: <TbMap2 fontSize={25} color={'#00AC11'} fontWeight={500} />,
        color: '#00AC11',
        link: '/region',
        text: 'Lokasi',
    },
    {
        id: 4,
        icon: <ProductIcons fontSize={25} color={'#A1469E'} />,
        color: '#A1469E',
        link: '/product',
        text: 'Produk',
    },

    {
        id: 5,
        icon: <BannerIcons fontSize={25} color={'#FDBE2E'} />,
        color: '#FDBE2E',
        link: '/banner',
        text: 'Banner',
    },
    {
        id: 6,
        icon: <CameraIcons fontSize={25} color={'#023670'} />,
        color: '#023670',
        link: '/activity',
        text: 'Aktivitas',
    },
]

export const ListItemHomeBranchAdmin: ListItemProps[] = [
    {
        id: 1,
        icon: <AccountIcons fontSize={25} color={'#1FB5EB'} />,
        color: '#1FB5EB',
        link: '/account',
        text: 'Akun',
    },
    {
        id: 2,
        icon: <BannerIcons fontSize={25} color={'#FDBE2E'} />,
        color: '#FDBE2E',
        link: '/customers',
        text: 'Pengajuan',
    },
    {
        id: 3,
        icon: <CameraIcons fontSize={25} color={'#023670'} />,
        color: '#023670',
        link: '/activity',
        text: 'Aktivitas',
    },
]

export const ListItemHomeSalesAdmin: ListItemProps[] = [
    {
        id: 1,
        icon: <OrderIcons fontSize={25} color={'#1FB5EB'} />,
        color: '#EE6C6B',
        link: '/order',
        text: 'Pesanan',
    },
    {
        id: 2,
        icon: <ProductIcons fontSize={25} color={'#A1469E'} />,
        color: '#A1469E',
        link: '/product',
        text: 'Produk',
    },
    {
        id: 4,
        icon: <PencilIcons fontSize={25} color={'#00AC11'} />,
        color: '#00AC11',
        link: '/target',
        text: 'Target',
    },
    {
        id: 3,
        icon: <UserIcons fontSize={25} color={'#00B8AA'} />,
        color: '#00B8AA',
        link: '/user',
        text: 'Akun',
    },
    {
        id: 4,
        icon: <IconShop fontSize={25} color={'#00B8AA'} />,
        color: '#00B8AA',
        link: '/business',
        text: 'Bisnis',
    },
    {
        id: 5,
        icon: <PencilIcons fontSize={25} color={'#00AC11'} />,
        color: '#00AC11',
        link: '/recipe',
        text: 'Resep',
    },
]

export const ListItemHomeFinanceAdmin: ListItemProps[] = [
    {
        id: 1,
        icon: <Receivables fontSize={25} color={'#EE6C6B'} />,
        color: '#EE6C6B',
        link: '/receivable/waiting',
        text: 'Invoice',
    },
    {
        id: 2,
        icon: <ProductIcons fontSize={25} color={'#A1469E'} />,
        color: '#A1469E',
        link: '/product/all/1',
        text: 'Produk',
    },
    {
        id: 3,
        icon: <BookIcon fontSize={25} color={'#00b8aa'} />,
        color: '#00b8aa',
        link: '/submission/history',
        text: 'Pengajuan',
    },
    {
        id: 4,
        icon: <CustomerIcon fontSize={25} color={'#00ac11'} />,
        color: '#00ac11',
        link: '/customer',
        text: 'Pelanggan',
    },
    {
        id: 5,
        icon: <BigDataIcon fontSize={25} color={'#013670'} />,
        color: '#013670',
        link: '/ekspor-data',
        text: 'Ekspor Data',
    },
]

export const ListItemHomeWarehouseAdmin: ListItemProps[] = [
    {
        id: 1,
        icon: <AccountIcons fontSize={25} color={'#1FB5EB'} />,
        color: '#1FB5EB',
        link: '/account-courier',
        text: 'Kurir',
    },
    {
        id: 2,
        icon: <ClipboardList fontSize={25} color={'#EE6C6B'} />,
        color: '#EE6C6B',
        link: '/delivery-create',
        text: 'Pesanan',
    },
    {
        id: 3,
        icon: <ProductIcons fontSize={25} color={'#A1469E'} />,
        color: '#A1469E',
        link: '/warehouse',
        text: 'Gudang',
    },
]

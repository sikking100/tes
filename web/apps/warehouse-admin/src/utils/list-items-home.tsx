import { Icons, Types } from 'ui'

export const ListItemHomeWarehouseAdmin: Types.ListItemProps[] = [
    {
        id: 1,
        icon: <Icons.AccountIcons fontSize={25} color={'#1FB5EB'} />,
        color: '#1FB5EB',
        link: '/account',
        text: 'Kurir',
    },
    {
        id: 2,
        icon: <Icons.ClipboardList fontSize={25} color={'#EE6C6B'} />,
        color: '#EE6C6B',
        link: '/order',
        text: 'Pesanan',
    },

    {
        id: 3,
        icon: <Icons.ProductIcons fontSize={25} color={'#A1469E'} />,
        color: '#A1469E',
        link: '/product',
        text: 'Produk',
    },
]

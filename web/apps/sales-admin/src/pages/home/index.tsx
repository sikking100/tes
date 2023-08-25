import { LayoutHome, Items, Icons, Types } from 'ui'
import { store } from 'hooks'
import React from 'react'
import { Eroles } from 'apis'

const HomePages = () => {
    const admin = store.useStore((i) => i.admin)

    const ListItemHomeSalesAdmin: Types.ListItemProps[] = [
        {
            id: 3,
            icon: <Icons.CustomerIcon fontSize={25} color={'#1FB5EB'} />,
            color: '#1FB5EB',
            link: '/user',
            text: 'Pelanggan',
        },
        {
            id: 1,
            icon: <Icons.OrderIcons fontSize={25} color={'#1FB5EB'} />,
            color: '#EE6C6B',
            link: '/order',
            text: 'Pesanan',
        },

        {
            id: 2,
            icon: <Icons.ProductIcons fontSize={25} color={'#A1469E'} />,
            color: '#A1469E',
            link: '/product',
            text: 'Produk',
        },

        {
            id: 5,
            icon: <Icons.PencilIcons fontSize={25} color={'#00AC11'} />,
            color: '#00AC11',
            link: '/recipe',
            text: 'Resep',
        },
        {
            id: 6,
            icon: <Icons.DataIcons fontSize={30} color={'#00AC11'} />,
            color: '#00AC11',
            link: '/report',
            text: 'Report',
        },
    ]

    const setList = React.useCallback(() => {
        if (admin?.roles === Eroles.SALES_ADMIN) {
            return ListItemHomeSalesAdmin.filter((i) => i.id !== Eroles.BRANCH_SALES_ADMIN)
        }
        return ListItemHomeSalesAdmin
    }, [admin])

    return (
        <div>
            <LayoutHome appName={'Sales'} list={setList()} isLoading={!admin ? true : false} />
        </div>
    )
}

export default HomePages

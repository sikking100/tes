import { Eroles } from 'apis'
import { Types } from 'ui'

export const setHeight = () => {
    if (window.screen.availWidth >= 1920) {
        return '72vh'
    }
    if (window.screen.availWidth >= 1535) {
        return '64vh'
    }
    if (window.screen.availWidth >= 1440) {
        return '60vh'
    }
    if (window.screen.availWidth >= 1366) {
        return '59vh'
    }

    return '100%'
}

export const listNavigation = (roles: number) => {
    const dataListTag: Types.ListSidebarProps[] = [
        {
            id: 1,
            link: '/product',
            title: 'Produk',
        },
        {
            id: 2,
            link: '/category-product',
            title: 'Kategori Produk',
        },
        {
            id: 5,
            link: '/code',
            title: 'Kode',
        },
    ]

    if (roles === Eroles.SALES_ADMIN) {
        return dataListTag
    }

    return dataListTag.filter((i) => i.id !== 5)
}

// export const TYPE_TEAM = [
//     { value: DataTypes.EmployeeTypes.Team.FOOD_SERVICE, label: 'Food Service' },
//     { value: DataTypes.EmployeeTypes.Team.RETAIL, label: 'Retail' },
// ]

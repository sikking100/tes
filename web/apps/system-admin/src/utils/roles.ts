import { Eroles } from 'apis'
import { entity } from 'ui'

export const ROLES_ADMIN = [
    { value: `${Eroles.SYSTEM_ADMIN}`, label: 'System Admin' },
    { value: `${Eroles.SALES_ADMIN}`, label: 'Sales Admin' },
    { value: `${Eroles.FINANCE_ADMIN}`, label: 'Finance Admin' },
    { value: `${Eroles.BRANCH_ADMIN}`, label: 'Branch Admin' },
    { value: `${Eroles.BRANCH_SALES_ADMIN}`, label: 'Sales Admin Cabang' },
    { value: `${Eroles.BRANCH_FINANCE_ADMIN}`, label: 'Finance Admin Cabang' },
    { value: `${Eroles.BRANCH_WAREHOUSE_ADMIN}`, label: 'Warehouse Admin' },
]

// export const ROLES_EXCEP = [
//     { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
//     { value: `${Eroles.SALES}`, label: 'Sales Staff' },
//     { value: `${Eroles.FINANCE_ADMIN}`, label: 'Finance Admin' },
//     { value: `${Eroles.BRANCH_ADMIN}`, label: 'Branch Admin' },
// ]

export const ROLES_EMPLOYEE = [
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
    { value: `${Eroles.COURIER}`, label: 'Kurir' },
    { value: `${Eroles.SALES}`, label: 'Sales' },
]

export const TYPE_TEAM = [
    { value: `${entity.Team.FOOD_SERVICE}`, label: 'Food Service' },
    { value: `${entity.Team.RETAIL}`, label: 'Retail' },
]

export const ROLES_FOOD_SERVICE = [
    { value: `${Eroles.GENERAL_MANAGER}`, label: 'General Manager' },
    { value: `${Eroles.NASIONAL_SALES_MANAGER}`, label: 'Nasional Sales Manager' },
    { value: `${Eroles.REGIONAL_MANAGER}`, label: 'Regional Manager' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
    { value: `${Eroles.SALES}`, label: 'Sales' },
]

export const ROLES_RETAIL = [
    { value: `${Eroles.DIREKTUR}`, label: 'Direktur' },
    { value: `${Eroles.GENERAL_MANAGER}`, label: 'General Manager' },
    { value: `${Eroles.REGIONAL_MANAGER}`, label: 'Regional Manager' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
    { value: `${Eroles.SALES}`, label: 'Sales' },
]

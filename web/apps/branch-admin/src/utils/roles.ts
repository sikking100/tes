import { Eroles } from 'apis'
import { entity } from 'ui'

export const ROLES_ADMIN = [
    { value: `${Eroles.BRANCH_FINANCE_ADMIN}`, label: 'Finance Admin' },
    { value: `${Eroles.BRANCH_SALES_ADMIN}`, label: 'Sales Admin' },
    { value: `${Eroles.BRANCH_WAREHOUSE_ADMIN}`, label: 'Warehouse Admin' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
]

export const TYPE_ROLES = [
    { value: '-', label: '-' },
    { value: `${entity.Team.FOOD_SERVICE}`, label: 'Food Service' },
    { value: `${entity.Team.RETAIL}`, label: 'Retail' },
]

export const ROLES_FOOD_SERVICE = [
    { value: `${Eroles.GENERAL_MANAGER}`, label: 'General Manager' },
    { value: `${Eroles.NASIONAL_SALES_MANAGER}`, label: 'Nasional Sales Manager' },
    { value: `${Eroles.REGIONAL_MANAGER}`, label: 'Regional Manager' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
]

export const ROLES_RETAIL = [
    { value: `${Eroles.DIREKTUR}`, label: 'Direktur' },
    { value: `${Eroles.GENERAL_MANAGER}`, label: 'General Manager' },
    { value: `${Eroles.REGIONAL_MANAGER}`, label: 'Regional Manager' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
]

export const TYPE_TEAM = [
    { value: '0', label: '-' },
    { value: `${entity.Team.FOOD_SERVICE}`, label: 'Food Service' },
    { value: `${entity.Team.RETAIL}`, label: 'Retail' },
]

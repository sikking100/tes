import { Eroles, SelectsTypes } from 'apis'

export const StatusTax: SelectsTypes[] = [
    {
        label: 'NON PKP',
        value: '0',
    },
    {
        label: 'PKP',
        value: '1',
    },
]

export const DayTax: SelectsTypes[] = [
    {
        label: 'SENIN',
        value: '1',
    },
    {
        label: 'SELASA',
        value: '2',
    },
    {
        label: 'RABU',
        value: '3',
    },
    {
        label: 'KAMIS',
        value: '4',
    },
    {
        label: 'JUMAT',
        value: '5',
    },
    {
        label: 'SABTU',
        value: '6',
    },
    {
        label: 'MINGGU',
        value: '0',
    },
]

export const rolesData = [
    {
        value: '0',
        label: 'All',
    },
    {
        value: `${Eroles.SALES_ADMIN}`,
        label: 'Sales Admin',
    },
    {
        value: `${Eroles.BRANCH_SALES_ADMIN}`,
        label: 'Branch Sales Admin',
    },
    {
        value: `${Eroles.DIREKTUR}`,
        label: 'Direktur',
    },
    {
        value: `${Eroles.GENERAL_MANAGER}`,
        label: 'General Manager',
    },
    {
        value: `${Eroles.NASIONAL_SALES_MANAGER}`,
        label: 'Nasional Sales Manager',
    },
    {
        value: `${Eroles.REGIONAL_MANAGER}`,
        label: 'Regional Manager',
    },
    {
        value: `${Eroles.AREA_MANAGER}`,
        label: 'Area Manager',
    },
    {
        value: `${Eroles.SALES}`,
        label: 'Sales',
    },
]

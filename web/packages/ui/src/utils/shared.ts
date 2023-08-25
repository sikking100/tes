// import { DataTypes } from 'api'
import { appName } from '../types'

export const StrRegConv = (s: string): string => {
  return s.replace(/-/g, ' ')
}

export const TextAlertRemove = (prefix: string): string => {
  return `Menghapus ${prefix} akan terhapus secara permanen di dalam sistem`
}

export function FormatDateToString(v: string): string {
  return new Intl.DateTimeFormat('id', {
    hour12: false,
    hour: 'numeric',
    minute: 'numeric',
    year: 'numeric',
    month: 'short',
    day: '2-digit',
  }).format(new Date(v))
}
export const splitText = (val: string, max: number): string => {
  return `${val.length > max ? `${val.substring(0, max)} ...` : val}`
}

// export const useRoles = (appName: appName) => {
//   const roles =
//     appName === 'System'
//       ? DataTypes.EmployeeTypes.Roles.SYSTEM_ADMIN
//       : appName === 'Branch'
//         ? DataTypes.EmployeeTypes.Roles.BRANCH_ADMIN
//         : appName === 'Sales'
//           ? DataTypes.EmployeeTypes.Roles.SALES_ADMIN
//           : appName === 'Finance'
//             ? DataTypes.EmployeeTypes.Roles.FINANCE_ADMIN
//             : DataTypes.EmployeeTypes.Roles.WAREHOUSE_ADMIN

//   return roles
// }

export const RegExPhoneNumber = /^[0-9 ()+]{7,16}$/
export const RegExNumber = /^\d+$/
export const RegExEmail = /\S+@\S+\.\S+/

export const formatRupiah = (angka: string): string => {
  const prefix = 'Rp '
  const number_string = angka.replace(/[^,\d]/g, '').toString(),
    split = number_string.split(','),
    sisa = split[0].length % 3,
    ribuan = split[0].substr(sisa).match(/\d{3}/gi)
  let rupiah = split[0].substr(0, sisa)

  if (ribuan) {
    const separator = sisa ? '.' : ''
    rupiah += separator + ribuan.join('.')
  }

  rupiah = split[1] != undefined ? rupiah + ',' + split[1] : rupiah
  return prefix == undefined ? rupiah : rupiah ? 'Rp ' + rupiah : ''
}

export const tommorowDate = (date: string): string => {
  const newDate = new Date(date)
  newDate.setDate(newDate.getDate() + 1)
  return newDate.toISOString()
}

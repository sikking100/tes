import { Icons, Types } from 'ui'

export const ListItemHomeBranch: Types.ListItemProps[] = [
  {
    id: 1,
    icon: <Icons.AccountIcons fontSize={25} color={'#1FB5EB'} />,
    color: '#1FB5EB',
    link: '/account',
    text: 'Akun',
  },
  {
    id: 2,
    icon: <Icons.CustomerIcon fontSize={25} color={'#1FB5EB'} />,
    color: '#1FB5EB',
    link: '/customer',
    text: 'Pelanggan',
  },
  {
    id: 3,
    icon: <Icons.ProductIcons fontSize={25} color={'#A1469E'} />,
    color: '#A1469E',
    link: '/warehouse',
    text: 'Gudang',
  },
  {
    id: 4,
    icon: <Icons.CameraIcons fontSize={25} color={'#023670'} />,
    color: '#023670',
    link: '/activity',
    text: 'Aktivitas',
  },
]

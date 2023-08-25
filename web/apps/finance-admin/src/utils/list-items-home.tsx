import { Icons, Types } from 'ui'

export const ListItemHome: Types.ListItemProps[] = [
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
    id: 4,
    icon: <Icons.CustomerIcon fontSize={25} color={'#1FB5EB'} />,
    color: '#1FB5EB',
    link: '/customer',
    text: 'Pelanggan',
  },
  {
    id: 5,
    icon: <Icons.DataIcons fontSize={25} color={'#00AC11'} />,
    color: '#00AC11',
    link: '/report',
    text: 'Report',
  },
]

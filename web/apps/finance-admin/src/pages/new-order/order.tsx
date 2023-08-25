import { Box, HStack, Spinner, TabPanel, Text } from '@chakra-ui/react'
import React from 'react'
import {
  ButtonTooltip,
  Columns,
  Icons,
  InputSearch,
  PagingButton,
  Root,
  Shared,
  Tables,
  Types,
  entity,
} from 'ui'
import { Invoice, Order } from 'apis'
import { dataListOrder } from '~/navigation'
import { orderService, store } from 'hooks'
import { DetailOrder } from './detail-order'


const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <Root appName='Finance' items={dataListOrder} backUrl={'/'} activeNum={1}>
    {children}
  </Root>
)

const OrderPages = () => {
  const admin = store.useStore((i) => i.admin)
  const [idOrder, setOrderId] = React.useState('')
  const [dataOrder, setDataOrder] = React.useState<Order[]>([])
  const { data, error, isLoading, onSetQuery, page } = orderService.useGetOrder()
  const orderDetail = orderService.useGetOrderById(idOrder)
  const { column, isOpen, setOpen, selectData } = columns()
  React.useEffect(() => {
    if (orderDetail?.data) {
      setDataOrder([orderDetail.data])
    }
    if (!idOrder) {
      setDataOrder([])
    }
  }, [idOrder, orderDetail.isLoading])
  // console.log(data);
  

  return (
    <Wrap>
      {isOpen && selectData && (
        <DetailOrder isOpen={isOpen} setOpen={setOpen} idOrder={selectData.id} />
      )}

      <Box mb={'10px'}>
        <InputSearch
          placeholder='Ketik Id Pesanan'
          text={idOrder}
          onChange={(e) => setOrderId(e.target.value)}
        />
      </Box>
      <Tables
        columns={column}
        data={dataOrder.length > 0 ? dataOrder : data?.items}
        isLoading={isLoading}
        usePaging={true}
      />
      <PagingButton
        page={Number(page)}
        nextPage={() => onSetQuery({ page: Number(page) + 1 })}
        prevPage={() => onSetQuery({ page: Number(page) - 1 })}
        disableNext={data?.next === null}
      />
    </Wrap>
  )
}

export default OrderPages

const columns = () => {
  const [selectData, setSelectData] = React.useState<Order>()
  const [isOpen, setOpen] = React.useState(false)
  const [isOpenPayInvoice, setOpenPayInvoice] = React.useState(false)
  const cols = Columns.columnsOrder

  const column: Types.Columns<Order>[] = [
    cols.id,
    cols.customer,
    cols.creator,
    cols.product,
    cols.status,
    cols.createdAt,
    {
      header: 'Aksi',
      render: (v) => (
        <HStack>
          <ButtonTooltip
            label={'Detail'}
            icon={<Icons.IconDetails color={'gray'} />}
            onClick={() => {
              setOpen(true)
              setSelectData(v)
            }}
          />
          {/* <ButtonTooltip
            label={'Invoice'}
            icon={<Icons.IconPaper color={'gray'} />}
            onClick={() => {
              setOpenPayInvoice(true)
              setSelectData(v)
            }}
          /> */}
        </HStack>
      ),
    },
  ]

  return {
    column,
    selectData,
    isOpen,
    setOpen,
    isOpenPayInvoice,
    setOpenPayInvoice,
  }
}

export const columnsInvoice = () => {
  const [selectData, setSelectData] = React.useState<Invoice>()
  const [selectIdOrder, setSelectIdOrder] = React.useState<string>()
  const [isOpen, setOpen] = React.useState(false)
  const [isOpenOrder, setOpenOrder] = React.useState(false)

  const column: Types.Columns<Invoice>[] = [
    {
      header: 'No Invoice',
      render: (v) => <Text>{v.id}</Text>,
    },
    {
      header: 'Metode Pembyaran',
      render: (v) => <Text>{entity.paymentMethod(v.paymentMethod)}</Text>,
    },
    {
      header: 'Jumlah',
      render: (v) => <Text>{Shared.formatRupiah(String(v.price))}</Text>,
    },

    {
      header: 'Status',
      render: (v) => <Text>{entity.statusInvoice(v.status)}</Text>,
    },
    {
      header: 'Pelanggan',
      render: (v) => (
        <Box>
          <Text>{v.customer.name}</Text>
          <Text>{v.customer.phone}</Text>
        </Box>
      ),
    },
    {
      header: 'Order',
      render: (v) => (
        <Text
          cursor={'pointer'}
          textDecor={'underline'}
          onClick={() => {
            setSelectIdOrder(v.orderId)
            setOpenOrder(true)
          }}
        >
          Lihat Pesanan
        </Text>
      ),
    },
    {
      header: 'Aksi',
      render: (v) => {
        return (
          <HStack>
            <ButtonTooltip
              label={'Detail'}
              icon={<Icons.IconDetails color={'gray'} />}
              onClick={() => {
                setOpen(true)
                setSelectData(v)
              }}
            />
          </HStack>
        )
      },
    },
  ]

  return {
    column,
    isOpenOrder,
    selectIdOrder,
    setSelectIdOrder,
    isOpen,
    selectData,
  }
}

import React from 'react'
import { ButtonTooltip, Columns, Icons, PText, Tables, Types, Root, TabsComponent } from 'ui'
import { orderService } from 'hooks'
import { dataListOrder } from '~/navigation'
import { TabPanel } from '@chakra-ui/tabs'
import { Box } from '@chakra-ui/react'
import { OrderApply, TypeOrderApply } from 'apis'
import OrderApplyDetail from './order-apply-detail'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <Root appName='Sales' items={dataListOrder} backUrl={'/'} activeNum={2}>
    {children}
  </Root>
)

const OrderApplyy: React.FC<{ type: TypeOrderApply }> = ({ type }) => {
  const { column, isOpen, setIsOpen, id } = columns(
    type === TypeOrderApply.WAITING_APPROVE ? true : false,
  )
  const { data, error, isLoading } = orderService.useGetOrderApply({ type })

  return (
    <Box mt={'5px'}>
      {isOpen && id && <OrderApplyDetail isOpen={isOpen} setOpen={setIsOpen} id={id.id} />}
      {error ? (
        <PText label={error} />
      ) : (
        <React.Fragment>
          <Tables
            useTab={true}
            isLoading={isLoading}
            columns={column}
            data={isLoading ? [] : data}
          />
        </React.Fragment>
      )}
    </Box>
  )
}

const OrderApplyPages = () => {
  const items = ['SEMUA', 'PENDING']
  return (
    <Wrap>
      <TabsComponent TabList={items} defaultIndex={0}>
        {items.map((i, k) => {
          const type = i === 'SEMUA' ? TypeOrderApply.HISTORY : TypeOrderApply.WAITING_APPROVE

          return (
            <TabPanel px={0} key={k}>
              <OrderApplyy type={type} />
            </TabPanel>
          )
        })}
      </TabsComponent>
    </Wrap>
  )
}
export default OrderApplyPages

const columns = (isWaiting: boolean) => {
  const [id, setId] = React.useState<OrderApply>()
  const [isOpen, setIsOpen] = React.useState(false)
  const cols = Columns.columnsOrderApply
  const column: Types.Columns<OrderApply>[] = [
    cols.id,
    cols.overDue,
    cols.overLimit,
    cols.status,
    cols.expiredAt,
    {
      header: 'Aksi',
      render: (v) => (
        <ButtonTooltip
          label={'Detail'}
          isDisabled={!!isWaiting}
          icon={<Icons.IconDetails color={'gray'} />}
          onClick={() => {
            setIsOpen(true)
            setId(v)
          }}
        />
      ),
    },
  ]

  return {
    column,
    id,
    isOpen,
    setIsOpen,
  }
}

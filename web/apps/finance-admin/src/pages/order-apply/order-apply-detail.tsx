import React from 'react'
import { orderService, store } from 'hooks'
// import { useNavigate, useParams } from 'react-router-dom'
import { ButtonForm, entity, LoadingForm, Modals, PText, Shared, Tables, Types } from 'ui'
import { Box, Divider, HStack, Text } from '@chakra-ui/layout'
import { Avatar, FormControl, FormLabel, Input } from '@chakra-ui/react'
import { StatusOrderApply, UserApproverOrder } from 'apis'

interface Props {
  isOpen: boolean
  setOpen: (v: boolean) => void
  id: string
}

const OrderApplyDetail: React.FC<Props> = ({ isOpen, setOpen, id }) => {
  const admin = store.useStore((v) => v.admin)
  const { column } = columns()
  const [note, setNote] = React.useState('')
  const [isLoadings, setIsLoadings] = React.useState(false)
  const { data, error, isLoading } = orderService.useGetOrderApplyById(`${id}`)
  const {
    data: dataOrder,
    error: errorDataOrder,
    isLoading: isLoadingDataOrder,
  } = orderService.useGetOrderById(`${id}`)
  const { approveOrder, rejectOrder } = orderService.useOrderApply()

  const onClose = () => setOpen(false)

  const onSubmit = async (isApprove: boolean) => {
    setIsLoadings(true)

    if (isApprove) {
      await approveOrder
        .mutateAsync({
          note: note || '-',
          idOrder: `${id}`,
          userId: `${admin?.id}`,
          userApprover: data.userApprover,
        })
        .finally(() => setIsLoadings(false))
    } else {
      await rejectOrder
        .mutateAsync({
          note: note || '-',
          idOrder: `${id}`,
          userId: `${admin?.id}`,
          userApprover: data.userApprover,
        })
        .finally(() => setIsLoadings(false))
    }
    setIsLoadings(false)
    onClose()
  }

  const findCurrentApprover = () => {
    if (!admin) return false
    const find = data.userApprover.find(
      (v) => v.id === admin.id && v.status === StatusOrderApply.WAITING_APPROVE,
    )
    if (find) return true
    return false
  }

  return (
    <Modals isOpen={isOpen} setOpen={onClose} title='Approval' size='5xl'>
      <Box>
        {error || errorDataOrder ? (
          <PText label={error || errorDataOrder || 'Coba beberapa saat lagi.'} />
        ) : isLoading || isLoadingDataOrder ? (
          <LoadingForm />
        ) : (
          <React.Fragment>
            <HStack experimental_spaceX={8}>
              <Box experimental_spaceY={2} fontWeight={'semibold'}>
                <HStack>
                  <Avatar
                    size={'xl'}
                    src={dataOrder.customer.imageUrl}
                    name={dataOrder.customer.name}
                  />
                  <Box>
                    <Text>{dataOrder.customer.name}</Text>
                    <Text>{dataOrder.customer.phone}</Text>
                    <Text>{dataOrder.customer.email}</Text>
                  </Box>
                </HStack>
              </Box>
            </HStack>

            <Divider my={2} />
            <Box>
              <Tables
                isLoading={isLoading}
                columns={column}
                data={isLoading ? [] : data.userApprover}
                pageH='100%'
              />
            </Box>

            {findCurrentApprover() && (
              <React.Fragment>
                <FormControl>
                  <FormLabel>Catatan</FormLabel>
                  <Input onChange={(e) => setNote(e.target.value)} value={note} />
                </FormControl>
                <ButtonForm
                  type='button'
                  onClick={() => onSubmit(true)}
                  label='Terima'
                  labelClose='Tolak'
                  onClose={() => onSubmit(false)}
                  isLoading={isLoadings}
                />
              </React.Fragment>
            )}
          </React.Fragment>
        )}
      </Box>
    </Modals>
  )
}

const columns = () => {
  const column: Types.Columns<UserApproverOrder>[] = [
    {
      header: 'Nama',
      render: (v) => (
        <HStack>
          <Avatar src={v.imageUrl} name={v.name} />
          <Text>{v.name}</Text>
        </HStack>
      ),
    },
    {
      header: 'Nomor HP',
      render: (v) => <Text>{v.phone}</Text>,
    },
    {
      header: 'Email',
      render: (v) => <Text>{v.email}</Text>,
    },
    {
      header: 'Status',
      render: (v) => <Text>{entity.statusOrderApply(v.status)}</Text>,
    },
    {
      header: 'Catatan',
      render: (v) => <Text>{v.note || '-'}</Text>,
    },
  ]

  return {
    column,
  }
}

export default OrderApplyDetail

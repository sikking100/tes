import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getPriceListApiInfo, PriceList, CreatePriceList, Type } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'price-list'
type Create = CreatePriceList & Type

export const useGetPriceList = () => {
  const query = useQuery<PriceList[], Error>(
    [key],
    asyncHandler(async () => {
      const res = await getPriceListApiInfo().find()
      return res
    }),
  )

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useGetPriceListById = (id: string) => {
  const query = useQuery<PriceList, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getPriceListApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const usePriceList = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })
  let textMessage = ''

  const onCreate = asyncHandler(async (data: CreatePriceList) => {
    const res = await getPriceListApiInfo().create(data)
    return res
  })

  const create = useMutation<PriceList, Error, Create>(
    asyncHandler(async (data) => {
      textMessage = data.t === 'create' ? 'ditambahkan' : 'diperbarui'
      const res = await getPriceListApiInfo().create(data)
      return res
    }),
    toasts({
      title: 'Kategori Harga',
      description: `Kategori harga berhasil ${textMessage}`,
      status: 'success',
    }),
  )

  const remove = useMutation<PriceList, Error, string>(
    asyncHandler(async (id) => {
      const res = await getPriceListApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Kategori Harga',
      description: `Kategori harga berhasil dihapus`,
      status: 'success',
    }),
  )

  return {
    create,
    remove,
    onCreate,
  }
}

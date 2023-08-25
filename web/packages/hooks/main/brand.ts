import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getBrandApiInfo, Brand, CreateBrand, Type } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'brand'
type Create = CreateBrand & Type

export const useGetBrand = () => {
  const query = useQuery<Brand[], Error>(
    [key],
    asyncHandler(async () => {
      const res = await getBrandApiInfo().find()
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useGetBranById = (id: string) => {
  const query = useQuery<Brand, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getBrandApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useBrand = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const create = useMutation<Brand, Error, Create>(
    asyncHandler(async (data) => {
      const res = await getBrandApiInfo().create(data)
      return res
    }),
    toasts({
      title: 'Brand',
      description: `Brand berhasi`,
      status: 'success',
    }),
  )

  const remove = useMutation<Brand, Error, string>(
    asyncHandler(async (id) => {
      const res = await getBrandApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Brand',
      description: 'Brand berhasil dihapus',
      status: 'success',
    }),
  )

  return {
    create,
    remove,
  }
}

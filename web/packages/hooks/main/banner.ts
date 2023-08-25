import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getBannerApiInfo, Banner, CreateBanner, BannerType } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'banner'

export const useGetBanner = (r: BannerType) => {
  const query = useQuery<Banner[], Error>(
    [key],
    asyncHandler(async () => {
      const res = await getBannerApiInfo().find(r)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useBanner = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const create = useMutation<void, Error, CreateBanner>(
    asyncHandler(async (data) => {
      await getBannerApiInfo().create(data)
    }),
    toasts({
      title: 'Banner',
      description: `Banner berhasil ditambahkan`,
      status: 'success',
    }),
  )

  const remove = useMutation<Banner, Error, string>(
    asyncHandler(async (id) => {
      const res = await getBannerApiInfo().deleteById(id)
      return res
    }),
    toasts({
      title: 'Banner',
      description: `Banner berhasil dihapus`,
      status: 'success',
    }),
  )

  return {
    create,
    remove,
  }
}

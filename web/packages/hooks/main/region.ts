import React from 'react'
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getRegionApiInfo, Region, CreateRegion, Type, ResPaging } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'
import { regionSchema } from '../validation'

const key = 'region'
type Create = CreateRegion & Type

export const useGetRegion = () => {
  const queryClient = useQueryClient()
  const [page, setPage] = React.useState(1)
  const [limit, setLimit] = React.useState(20)
  const [q, setQ] = React.useState('')

  const find = asyncHandler(async () => {
    const res = await getRegionApiInfo().find({ page, limit, search: q })
    return res
  })

  const query = useQuery<ResPaging<Region>, Error>([key, page, limit, q], find)

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, page, limit, q], find)
    }
  }, [query.data, query.isPreviousData, page, queryClient, limit, q])

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setLimit,
    limit,
    setQ,
  }
}

export const useGetRegionById = (id: string) => {
  const query = useQuery<Region, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getRegionApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useRegion = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const onCreate = asyncHandler(async (r: Create) => {
    const res = await getRegionApiInfo().create(r)
    return res
  })

  const create = useMutation<Region, Error, Create>(
    asyncHandler(async (r: Create) => {
      await regionSchema.parseAsync(r)
      const res = await getRegionApiInfo().create(r)
      return res
    }),
    toasts({
      title: 'Region',
      description: `Region berhasil`,
      status: 'success',
    }),
  )

  const remove = useMutation<Region, Error, string>(
    asyncHandler(async (id) => {
      const res = await getRegionApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Region',
      description: `Region berhasil dihapus`,
      status: 'success',
    }),
  )

  return {
    create,
    remove,
    onCreate,
  }
}

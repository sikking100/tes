import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Code, getCodeApiInfo, CreateCode, ReqPaging, ResPaging } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'
import React from 'react'

const key = 'code'

export const useGetCode = () => {
  const queryClient = useQueryClient()

  const [q, setQ] = React.useState<ReqPaging>({
    page: 1,
    limit: 10,
  })

  const onSetQuery = (e: ReqPaging) => {
    setQ((i) => {
      return { ...i, ...e }
    })
  }

  const find = asyncHandler(async () => {
    const res = await getCodeApiInfo().find({
      page: q.page,
      limit: q.limit,
    })
    return res
  })

  const query = useQuery<ResPaging<Code>, Error>([key], find)

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, q], find)
    }
  }, [query.data, query.isPreviousData, queryClient, q])

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
    q,
  }
}

export const useGetCodyById = (id: string) => {
  const query = useQuery<Code, Error>(
    [key, id],
    asyncHandler(async () => getCodeApiInfo().findById(id)),
  )

  return {
    data: query.error ? undefined : query.isLoading ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useCode = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const create = useMutation<Code, Error, CreateCode>(
    asyncHandler(async (ReqData: CreateCode) => {
      const res = await getCodeApiInfo().create(ReqData)
      return res
    }),
    toasts({
      title: 'Code',
      description: 'Code berhasil ditambahkan',
      status: 'success',
    }),
  )

  const remove = useMutation<Code, Error, string>(
    asyncHandler(async (id: string) => {
      const res = await getCodeApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Code',
      description: 'Code berhasil dihapus',
      status: 'success',
    }),
  )

  return {
    create,
    remove,
  }
}

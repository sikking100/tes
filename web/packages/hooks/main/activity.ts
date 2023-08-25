import React from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Activity, getActivityApiInfo, ResPaging, CreateActivity, UpdateActivity } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'
import { useToast } from '../utils/toast'

const key = 'activity'

export const useGetActivity = () => {
  const queryClient = useQueryClient()
  const [page, setPage] = React.useState(1)
  const [limit, setLimit] = React.useState(20)

  const byPaging = asyncHandler(async () => {
    const res = await getActivityApiInfo().find({ page, limit })
    return res
  })

  const query = useQuery<ResPaging<Activity>, Error>([key, page, limit], byPaging)

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, page, limit], byPaging)
    }
  }, [query.data, query.isPreviousData, page, queryClient, limit])

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setLimit,
    limit,
  }
}

export const useGetActivityById = (id: string) => {
  const query = useQuery<Activity, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getActivityApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useActivity = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const create = useMutation<void, Error, CreateActivity>(
    asyncHandler(async (data: CreateActivity) => {
      const ReqData: CreateActivity = {
        ...data,
        creator: {
          ...data.creator,
          description: '-',
        },
        videoUrl: data?.videoUrl || '-',
      }
      await getActivityApiInfo().create(ReqData)
    }),
    toasts({
      title: 'Activity',
      description: 'Activity berhasil ditambahkan',
      status: 'success',
    }),
  )

  const update = useMutation<void, Error, UpdateActivity>(
    asyncHandler(async (data: UpdateActivity) => {
      const ReqData: UpdateActivity = {
        ...data,
        creator: {
          ...data.creator,
          description: '-',
        },
        videoUrl: data?.videoUrl || '-',
      }
      await getActivityApiInfo().update(ReqData)
    }),
    toasts({
      title: 'Activity',
      description: 'Activity berhasil diperbarui',
      status: 'success',
    }),
  )

  const remove = useMutation<void, Error, string>(
    asyncHandler(async (id: string) => {
      await getActivityApiInfo().delete(id)
    }),
    toasts({
      title: 'Activity',
      description: 'Activity berhasil dihapus',
      status: 'success',
    }),
  )

  return {
    create,
    update,
    remove,
  }
}

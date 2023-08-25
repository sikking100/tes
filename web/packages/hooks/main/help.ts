import React from 'react'
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { getHelpApiInfo, Help, CreateHelp, CreateQuestion, ResPaging } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'help'

interface Req {
  isAnswered?: boolean
  userId?: string
  isHelp?: boolean
}

export const useGetHelp = (r: Req) => {
  const queryClient = useQueryClient()
  const [page, setPage] = React.useState(1)
  const [limit, setLimit] = React.useState(20)
  const [q, setQ] = React.useState('')

  const find = asyncHandler(async () => {
    const res = await getHelpApiInfo().find({
      page,
      limit,
      search: q,
      isAnswered: r.isAnswered,
      userId: r.userId,
      isHelp: r.isHelp,
    })
    return res
  })

  const query = useQuery<ResPaging<Help>, Error>(
    [key, page, limit, q, r.isAnswered, r.userId],
    find,
  )

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, page, limit, q, r.isAnswered, r.userId], find)
    }
  }, [query.data, query.isPreviousData, page, queryClient, limit, q, r.isAnswered, r.userId])

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

export const useGetHelpById = (id: string) => {
  const query = useQuery<Help, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getHelpApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useHelp = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const createHelp = useMutation<Help, Error, CreateHelp>(
    asyncHandler(async (req) => {
      const res = await getHelpApiInfo().createHelp(req)
      return res
    }),
    toasts({
      title: 'Bantuan',
      description: 'Bantuan berhasil ditambahkan',
      status: 'success',
    }),
  )

  const createQuestion = useMutation<Help, Error, CreateQuestion>(
    asyncHandler(async (req) => {
      const res = await getHelpApiInfo().createQuestion(req)
      return res
    }),
    toasts({
      title: 'Pertanyaan',
      description: 'Pertanyaan berhasil diajukan',
      status: 'success',
    }),
  )

  const updateHelp = useMutation<Help, Error, Help>(
    asyncHandler(async (req) => {
      const res = await getHelpApiInfo().updateHelp(req)
      return res
    }),
    toasts({
      title: 'Bantuan',
      description: 'Bantuan berhasil diperbarui',
      status: 'success',
    }),
  )

  const updateQuestion = useMutation<Help, Error, Help>(
    asyncHandler(async (req) => {
      const res = await getHelpApiInfo().updateQuestion(req)
      return res
    }),
    toasts({
      title: 'Pertanyaan',
      description: 'Pertanyaan berhasil dijawab',
      status: 'success',
    }),
  )

  const remove = useMutation<Help, Error, string>(
    asyncHandler(async (id: string) => {
      const res = await getHelpApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Bantuan',
      description: 'Bantuan berhasil dihapus',
      status: 'success',
    }),
  )

  return {
    createHelp,
    createQuestion,
    remove,
    updateHelp,
    updateQuestion,
  }
}

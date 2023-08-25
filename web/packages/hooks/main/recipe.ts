import { asyncHandler } from './../utils/async'
import { useQueryClient, useQuery, useMutation } from '@tanstack/react-query'
import { CreateRecipe, getRecipeApiInfo, ResPaging, Recipe } from 'apis'
import { useState, useEffect } from 'react'
import { useToast } from '../utils/toast'
import { useAlert } from '../utils/on-alert'

const key = 'recipe'

export const useGetRecipe = (category?: string) => {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [q, setQ] = useState('')

  const find = asyncHandler(async () => {
    const res = await getRecipeApiInfo().find({ page, limit: 20, search: q, category })
    return res
  })

  const query = useQuery<ResPaging<Recipe>, Error>([key, page, q, category && category], find)

  useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, page, q, category && category], find)
    }
  }, [query.data, query.isPreviousData, page, queryClient, q, category && category])

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setQ,
  }
}

export const useGetRecipeById = (id: string) => {
  const query = useQuery<Recipe, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getRecipeApiInfo().findById(id)
      return res
    }),
  )

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useRecipe = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const create = useMutation<Recipe, Error, CreateRecipe>(
    asyncHandler(async (req) => {
      const res = await getRecipeApiInfo().create(req)
      return res
    }),
    toasts({
      title: 'Resep',
      description: 'Resep berhasil ditambahkan',
    }),
  )

  const update = useMutation<Recipe, Error, Recipe>(
    asyncHandler(async (req) => {
      const res = await getRecipeApiInfo().update(req)
      return res
    }),
    toasts({
      title: 'Resep',
      description: 'Resep berhasil diperbarui',
    }),
  )

  const remove = useMutation<Recipe, Error, string>(
    asyncHandler(async (id) => {
      const res = await getRecipeApiInfo().delete(id)
      return res
    }),
    toasts({
      title: 'Resep',
      description: 'Resep berhasil dihapus',
    }),
  )

  return {
    create,
    update,
    remove,
  }
}

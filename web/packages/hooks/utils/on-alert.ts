import type { UseToastOptions, ToastId } from '@chakra-ui/react'
import { QueryClient } from '@tanstack/react-query'

interface Porps {
  toast: ({ description, status, title }: UseToastOptions) => ToastId
  queryClient: QueryClient
  key: string
}

export const useAlert = (r: Porps) => {
  const alert = (opts?: UseToastOptions) => ({
    onSuccess: (_: any, d: any) => {
      r.toast({
        status: 'success',
        description:
          `${opts?.description} ${d.t === 'create' ? 'ditambahkan' : ''}` ||
          'Sukess menambahkan data',
        title: opts?.title || 'Sukess',
        position: 'bottom-right',
      })
      r.queryClient.invalidateQueries([r.key])
    },
    onError: (error: Error) => {
      r.toast({
        title: 'Error',
        description: error.message,
        status: 'error',
        position: 'bottom-right',
      })
    },
  })

  return alert
}

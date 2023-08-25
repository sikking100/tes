import React from 'react'
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  getDeliveryApiInfo,
  Delivery,
  ReqPackingList,
  ReqFindDelivery,
  ResPaging,
  CreatePackingList,
  SetInternalCourier,
  SetCourierExternal,
  UpdateQty,
  ActionPackingList,
  PackingListWarehousue,
  ProductDelivery,
  ReqFindProductByStatus,
  PackingListCourier,
  ReqPackingListCourier,
  ReqPackingListDestination,
  PackingListDestination,
  ReqFindProductByStatusDelivery,
  StatusDelivery,
  TypeReqDelivery,
  ActionPackingListRestock,
} from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'delivery'

export const useGetDelivery = () => {
  const queryClient = useQueryClient()
  const [querys, setQuerys] = React.useState<ReqFindDelivery>({
    branchId: '',
    limit: 20,
    page: 1,
    search: '',
    courierId: '',
    status: StatusDelivery.APPLY,
  })

  const onSetQuery = (req: ReqFindDelivery) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const byPaging = asyncHandler(async () => {
    const res = await getDeliveryApiInfo().find({
      ...querys,
    })
    return res
  })

  const query = useQuery<ResPaging<Delivery>, Error>([key, querys], byPaging)

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, querys], byPaging)
    }
  }, [query.data, query.isPreviousData, queryClient, querys])

  return {
    data: query.data,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
    page: querys.page,
  }
}

export const useGetDeliveryById = (id: string) => {
  const query = useQuery<Delivery, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findById(id)
      return res
    }),
  )
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useGetDeliveryOrderId = (orderId: string) => {
  const query = useQuery<Delivery[], Error>(
    [key, orderId],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findByOrder(orderId)
      return res
    }),
  )
  return {
    data: query.error ? undefined : query.isLoading ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  }
}

export const useGetPackingListWarehouse = () => {
  const [querys, setQuerys] = React.useState<ReqPackingList>({
    branchId: '',
    warehouseId: '',
    status: StatusDelivery.CREATE_PACKING_LIST,
  })

  const onSetQuery = (req: ReqPackingList) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const query = useQuery<PackingListWarehousue[], Error>(
    [key, querys],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findPackingListWarehouse(querys)
      return res
    }),
  )
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
  }
}

export const useGetPackingListCourier = () => {
  const [querys, setQuerys] = React.useState<ReqPackingListCourier>({
    courierId: '',
    status: 0,
  })

  const onSetQuery = (req: ReqPackingListCourier) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const query = useQuery<PackingListCourier[], Error>(
    [key, querys],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findPackingListCourier(querys)
      return res
    }),
  )
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
  }
}

export const useGetDeliveryByStatus = () => {
  const queryClient = useQueryClient()

  const [querys, setQuerys] = React.useState<ReqFindProductByStatusDelivery>({
    courierId: '',
    branchId: '',
    warehouseId: '',
    status: StatusDelivery.PENDING,
  })

  const onSetQuery = (req: ReqFindProductByStatusDelivery) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const find = asyncHandler(async () => {
    const res = await getDeliveryApiInfo().getProductByStatus(querys)
    return res
  })

  const query = useQuery<ProductDelivery[], Error>(['delivey-status-product', querys], find)

  React.useEffect(() => {
    if (!query.isPreviousData && query.data) {
      queryClient.prefetchQuery([key, querys], find)
    }
  }, [query.data, query.isPreviousData, queryClient, querys])


  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
  }
}

export const useGetPackingListDestination = () => {
  const [querys, setQuerys] = React.useState<ReqPackingListDestination>({
    courierId: '',
  })

  const onSetQuery = (req: ReqPackingListDestination) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const query = useQuery<PackingListDestination[], Error>(
    [key, querys],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findPackingListDestination(querys)
      return res
    }),
  )
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
  }
}

export const useGetProductByStatus = () => {
  const [querys, setQuerys] = React.useState<ReqFindProductByStatus>({
    courierId: '',
    status: undefined,
    warehouseId: '',
  })

  const onSetQuery = (req: ReqFindProductByStatus) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...req,
      }
    })
  }

  const query = useQuery<ProductDelivery[], Error>(
    [key, querys],
    asyncHandler(async () => {
      const res = await getDeliveryApiInfo().findProductByStatus(querys)
      return res
    }),
  )
  return {
    data: query.error ? [] : query.isLoading ? [] : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuery,
  }
}

export const useDelivery = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const createPackingList = useMutation(
    asyncHandler(async (r: CreatePackingList) => {
      const res = await getDeliveryApiInfo().createPackingList(r)
      return res
    }),
    toasts({
      description: 'Packing list berhasil dibuat',
    }),
  )

  const setCourierInternal = useMutation(
    asyncHandler(async (r: SetInternalCourier) => {
      const res = await getDeliveryApiInfo().setCourierInternal(r)
      return res
    }),
    toasts({
      description: 'Kurir internal berhasil ditambahkan',
    }),
  )

  const setCourierExternal = useMutation(
    asyncHandler(async (r: SetCourierExternal) => {
      const res = await getDeliveryApiInfo().setCourierExternal(r)
      return res
    }),
    toasts({
      description: 'Kurir external berhasil ditambahkan',
    }),
  )

  const setUpdateDelivertQty = useMutation(
    asyncHandler(async (r: UpdateQty) => {
      const res = await getDeliveryApiInfo().updateQty(r)
      return res
    }),
    toasts({
      description: 'Jumlah stok berhasil diperbarui',
    }),
  )

  const setUpdateLoadedPackingList = useMutation(
    asyncHandler(async (r: ActionPackingList) => {
      const res = await getDeliveryApiInfo().loadedPackingList(r)
      return res
    }),
    toasts({
      description: 'Berhasil update packing list',
    }),
  )

  const setRestockPackingList = useMutation(
    asyncHandler(async (r: ActionPackingListRestock) => {
      const res = await getDeliveryApiInfo().restockPackingList(r)
      return res
    }),
    toasts({
      description: 'Berhasil restock packing list',
    }),
  )

  return {
    createPackingList,
    setCourierInternal,
    setCourierExternal,
    setUpdateDelivertQty,
    setUpdateLoadedPackingList,
    setRestockPackingList,
  }
}

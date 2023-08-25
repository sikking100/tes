import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getOrderApiInfo,
  Order,
  ReqPageOrder,
  ResPaging,
  CreateOrder,
  CancelOrder,
  OrderApply,
  ApproveOrder,
  TypeOrderApply,
  ReportOrder,
  ReqOrderReport,
  ReqOrderPerformance,
  ReportPerformance,
} from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";
import { useEffect, useState } from "react";

const key = "order";
const keyApply = "order-apply";

export type TOrder = Omit<ReqPageOrder, "limit">;

export const useGetOrder = () => {
  const queryClient = useQueryClient();

  const [querys, setQuery] = useState<ReqPageOrder>({
    branchId: "",
    code: "",
    regionId: "",
    status: undefined,
    userid: "",
    limit: 20,
    page: 1,
    search: "",
  });

  const onSetQuery = (req: TOrder) => {
    setQuery((i) => {
      return { ...i, ...req };
    });
  };

  const find = asyncHandler(async () => {
    const res = await getOrderApiInfo().find({
      ...querys,
    });
    return res;
  });

  const query = useQuery<ResPaging<Order>, Error>([key, querys], find);

  useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, querys], find);
    }
  }, [query.data, query.isPreviousData, queryClient, querys]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    page: querys.page,
    onSetQuery,
  };
};

export const useGetOrderById = (id: string) => {
  const query = useQuery<Order, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getOrderApiInfo().findById(id);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useOrder = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  const create = useMutation<Order, Error, CreateOrder>(
    asyncHandler(async (req) => {
      const res = await getOrderApiInfo().create(req);
      return res;
    }),
    toasts({
      title: "Pesanan",
      description: "Pesanan berhasil dibuat",
      status: "success",
    })
  );

  const cancel = useMutation<Order, Error, CancelOrder>(
    asyncHandler(async (req) => {
      const res = await getOrderApiInfo().cancel(req);
      return res;
    }),
    toasts({
      title: "Pesanan",
      description: "Pesanan berhasil dibatalkan",
      status: "success",
    })
  );

  return {
    create,
    cancel,
  };
};

export const useGetOrderApply = (req: { type: TypeOrderApply }) => {
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(20);
  const [q, setQ] = useState("");

  const find = asyncHandler(async () => {
    const res = await getOrderApiInfo().findApply({
      type: req.type,
    });
    return res;
  });

  const query = useQuery<OrderApply[], Error>(
    [keyApply, page, limit, q, req.type],
    find
  );

  return {
    data: query.data || [],
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetOrderApplyById = (id: string) => {
  const query = useQuery<OrderApply, Error>(
    [keyApply, id],
    asyncHandler(async () => {
      const res = await getOrderApiInfo().findApplyById(id);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetOrderReport = (q: ReqOrderReport) => {
  const query = useQuery<ReportOrder[], Error>(
    ["order-report", q],
    asyncHandler(async () => {
      const res = await getOrderApiInfo().findReport(q);
      return res;
    }),
    {
      enabled: !!q.query,
    }
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetOrderPerformance = (q: ReqOrderPerformance) => {
  const query = useQuery<ReportPerformance[], Error>(
    ["order-peformance", q],
    asyncHandler(async () => {
      const res = await getOrderApiInfo().findPerformance(q);
      return res;
    }),
    {
      enabled: !!q.team,
    }
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useOrderApply = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key: keyApply, queryClient, toast });

  const approveOrder = useMutation<OrderApply, Error, ApproveOrder>(
    asyncHandler(async (req) => {
      const res = await getOrderApiInfo().approveOrderApply(req);
      return res;
    }),
    toasts({
      title: "Pesanan",
      description: "Pesanan berhasil disetujui",
    })
  );

  const rejectOrder = useMutation<OrderApply, Error, ApproveOrder>(
    asyncHandler(async (req) => {
      const res = await getOrderApiInfo().rejectOrderApply(req);
      return res;
    }),
    toasts({
      title: "Pesanan",
      description: "Pesanan berhasil ditolak",
    })
  );

  return {
    approveOrder,
    rejectOrder,
  };
};

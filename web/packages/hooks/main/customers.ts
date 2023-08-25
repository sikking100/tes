import React from "react";
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getCustomerApiInfo,
  Customers,
  ReqCustomerApplyGet,
  ResPaging,
  CustomerApply,
  CreateCustomerApply,
  UpdateBusiness,
  CreateNewLimit,
  ApproveLimit,
  ApproveApply,
  ApproveBranch,
  Reject,
  CreateCustomerNoAuth,
  ReqCustomerGet,
  RejectApply,
} from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";

type ReqCustomerApply = Omit<ReqCustomerApplyGet, "page" | "limit" | "search">;

const key = "customers";
const keyApply = "customers-apply";

export const useGetCustomers = () => {
  const queryClient = useQueryClient();
  const [querys, setQuerys] = React.useState<ReqCustomerGet>({
    page: 1,
    limit: 20,
    search: "",
    branchId: "",
    viewer: undefined,
  });
  const [q, setQ] = React.useState("");

  const onSetQuerys = (e: ReqCustomerGet) => {
    setQuerys((i) => {
      return { ...i, ...e };
    });
  };

  const byPaging = asyncHandler(async () => {
    const res = await getCustomerApiInfo().findCustomer(querys);
    return res;
  });

  const query = useQuery<ResPaging<Customers>, Error>([key, querys], byPaging);

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, querys], byPaging);
    }
  }, [query.data, query.isPreviousData, queryClient, querys]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    page: Number(querys.page),
    limit: Number(querys.limit),
    setQ,
    onSetQuerys,
  };
};

export const useGetCustomerById = (id: string) => {
  const query = useQuery<Customers, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getCustomerApiInfo().findCustomerById(id);
      return res;
    })
  );
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetCustomerApplyById = (id: string) => {
  const query = useQuery<CustomerApply, Error>(
    [keyApply, id],
    asyncHandler(async () => {
      const res = await getCustomerApiInfo().findCustomerApplyById(id);
      return res;
    })
  );
  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetCustomerApply = (req: ReqCustomerApply) => {
  const queryClient = useQueryClient();
  const [page, setPage] = React.useState(1);
  const [limit, setLimit] = React.useState(20);
  const [q, setQ] = React.useState("");

  const byPaging = asyncHandler(async () => {
    const res = await getCustomerApiInfo().findCustomerApply({
      limit,
      page,
      search: q,
      userId: req.userId,
      type: req.type,
    });
    return res;
  });

  const query = useQuery<ResPaging<CustomerApply>, Error>(
    [keyApply, page, limit, q, req.type, req.userId],
    byPaging
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery(
        [keyApply, page, limit, q, req.userId, req.type],
        byPaging
      );
    }
  }, [
    query.data,
    query.isPreviousData,
    page,
    queryClient,
    limit,
    q,
    req.userId,
    req.type,
  ]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setLimit,
    limit,
    setQ,
  };
};


export const useCustomer = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  const createCustomer = useMutation(
    asyncHandler(async (req: CreateCustomerNoAuth) => {
      const res = await getCustomerApiInfo().createCustomer(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Pelanggan berhasil ditambahkan",
    })
  );

  const createCustomerApply = useMutation(
    asyncHandler(async (req: CreateCustomerApply) => {
      const res = await getCustomerApiInfo().createCustomerApply(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Bisnis berhasil ditambahkan",
    })
  );

  const updateBusiness = useMutation(
    asyncHandler(async (req: UpdateBusiness) => {
      const res = await getCustomerApiInfo().updateBusiness(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Bisnis berhasil diperbarui",
    })
  );

  const createApplyNewLimit = useMutation(
    asyncHandler(async (req: CreateNewLimit) => {
      const res = await getCustomerApiInfo().createApplyNewLimit(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Limit berhasil ditambahkan",
    })
  );

  const approveLimit = useMutation(
    asyncHandler(async (req: ApproveLimit) => {
      const res = await getCustomerApiInfo().approveLimit(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Limit berhasil disetujui",
    })
  );

  const approveApply = useMutation(
    asyncHandler(async (req: ApproveApply) => {
      const res = await getCustomerApiInfo().approveApply(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Bisnis berhasil disetujui",
    })
  );

  const approveBusinessForBranchAdmin = useMutation(
    asyncHandler(async (req: ApproveBranch) => {
      const res = await getCustomerApiInfo().approveBusiness(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Bisnis berhasil disetujui",
    })
  );

  const reject = useMutation(
    asyncHandler(async (req: RejectApply) => {
      const res = await getCustomerApiInfo().reject(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Bisnis berhasil ditolak",
    })
  );

  return {
    createCustomer,
    createCustomerApply,
    updateBusiness,
    createApplyNewLimit,
    approveLimit,
    approveApply,
    approveBusinessForBranchAdmin,
    reject,
  };
};

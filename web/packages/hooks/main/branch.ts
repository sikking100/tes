import React from "react";
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Branch,
  getBranchApiInfo,
  ResPaging,
  CreateBranch,
  CreateWarehouse,
  Type,
  Warehouse,
} from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";

const key = "branch";
type Create = CreateBranch & Type;
type CreateWare = {
  idBranch: string;
  listWarehouse: CreateWarehouse[];
};

type UpdateWarehouse = {
  r: Warehouse[];
  branchId: string;
};

export const useGetBranch = (regionId?: string) => {
  const queryClient = useQueryClient();
  const [page, setPage] = React.useState(1);
  const [limit, setLimit] = React.useState(20);
  const [q, setQ] = React.useState("");

  const find = asyncHandler(async () => {
    const res = await getBranchApiInfo().find({
      page,
      limit,
      regionId,
      search: q,
    });
    return res;
  });

  const query = useQuery<ResPaging<Branch>, Error>(
    [key, page, limit, q, regionId && regionId],
    find
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery(
        [key, page, limit, q, regionId && regionId],
        find
      );
    }
  }, [
    query.data,
    query.isPreviousData,
    page,
    queryClient,
    limit,
    q,
    regionId && regionId,
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

export const useGetBranchId = (id: string) => {
  const find = asyncHandler(async () => {
    const res = await getBranchApiInfo().findById(id);
    return res;
  });
  const query = useQuery<Branch, Error>([key, id], find);

  return {
    data: query.error ? undefined : query.data,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useBranch = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  const create = useMutation<Branch, Error, Create>(
    asyncHandler(async (r) => {
      const res = await getBranchApiInfo().create(r);
      return res;
    }),
    toasts({
      title: "Cabang",
      description: `Cabang berhasil`,
    })
  );

  const createWarehouse = useMutation<Branch, Error, CreateWare>(
    asyncHandler(async (r) => {
      const res = await getBranchApiInfo().createWarehouse(
        r.listWarehouse,
        r.idBranch
      );
      return res;
    }),
    toasts({
      title: "Gudang",
      description: `Gudang berhasil ditambahkan`,
    })
  );

  const removeWarehouse = useMutation<Branch, Error, UpdateWarehouse>(
    asyncHandler(async (req) => {
      const res = await getBranchApiInfo().updateWarehouse(req.r, req.branchId);
      return res;
    }),
    toasts({
      title: "Gudang",
      description: `Gudang berhasil dihapus`,
    })
  );

  const remove = useMutation<Branch, Error, string>(
    asyncHandler(async (id: string) => {
      const res = await getBranchApiInfo().delete(id);
      return res;
    }),
    toasts({
      title: "Cabang",
      description: "Cabang berhasil dihapus",
    })
  );

  return {
    create,
    remove,
    createWarehouse,
    removeWarehouse,
  };
};

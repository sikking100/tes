import React from "react";
import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  getEmployeeApiInfo,
  ResPaging,
  Employee,
  CreateEmployee,
  UpdateAccountEmployee,
} from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";

const key = "employee";
interface S {
  query?: string;
}

export const useGetEmployee = (req: S) => {
  const queryClient = useQueryClient();
  const [page, setPage] = React.useState(1);
  const [limit, setLimit] = React.useState(20);
  const [q, setQ] = React.useState("");

  const byPaging = asyncHandler(async () => {
    const res = await getEmployeeApiInfo().find({
      page,
      limit,
      query: req.query,
      search: q,
    });
    return res;
  });

  const query = useQuery<ResPaging<Employee>, Error>(
    [key, page, limit, q, req.query],
    byPaging
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([key, page, limit, q], byPaging);
    }
  }, [
    query.data,
    query.isPreviousData,
    page,
    queryClient,
    limit,
    q,
    req.query,
  ]);

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setLimit,
    limit,
    setQ,
  };
};

export const useGetByIdEmployee = (id: string) => {
  const query = useQuery<Employee, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getEmployeeApiInfo().findById(id);
      return res;
    })
  );
  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useEmployee = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  // const onCreate = asyncHandler(async (r: CreateEmployee) => {
  //   const res = await getEmployeeApiInfo().create(r)
  //   return res
  // })

  const create = useMutation(
    asyncHandler(async (req: CreateEmployee) => {
      const res = await getEmployeeApiInfo().create(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Akun berhasil ditambahkan",
      status: "success",
    })
  );
  const createUpdate = useMutation(
    asyncHandler(async (req: CreateEmployee) => {
      const res = await getEmployeeApiInfo().create(req);
      return res;
    }),
    toasts({
      title: "Akun",
      description: "Akun berhasil diperbarui",
      status: "success",
    })
  );


  const update = useMutation(
    async (r: UpdateAccountEmployee) => {
      const res = await getEmployeeApiInfo().update(r);
      return res;
    },
    toasts({
      title: "Akun",
      description: "Akun berhasil diperbarui",
      status: "success",
    })
  );

  const remove = useMutation(
    async (r: string) => {
      const res = await getEmployeeApiInfo().delete(r);
      return res;
    },
    toasts({
      title: "Akun",
      description: "Akun berhasil dihapus",
      status: "success",
    })
  );

  return {
    create,
    update,
    remove,
    createUpdate
  };
};

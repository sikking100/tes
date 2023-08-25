import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getCategoryApiInfo, Category, CreateCategory, Type } from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";

const key = "category";
type Create = CreateCategory & Type;

export const useGetCategory = () => {
  const query = useQuery<Category[], Error>(
    [key],
    asyncHandler(async () => {
      const res = await getCategoryApiInfo().find();
      return res;
    })
  );

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetCategoryById = (id: string) => {
  const query = useQuery<Category, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getCategoryApiInfo().findById(id);
      return res;
    })
  );

  return {
    data: query.error ? undefined : query.data,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useCategory = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  let textMessage = "";

  const create = useMutation<Category, Error, Create>(
    asyncHandler(async (data) => {
      textMessage = data.t === "create" ? "ditambahkan" : "diperbarui";
      const res = await getCategoryApiInfo().create(data);
      return res;
    }),
    toasts({
      title: "Kategori",
      description: `Kategori berhasil ${textMessage}`,
      status: "success",
    })
  );

  const remove = useMutation<Category, Error, string>(
    asyncHandler(async (id) => {
      const res = await getCategoryApiInfo().delete(id);
      return res;
    }),
    toasts({
      title: "Kategori",
      description: "Kategori berhasil dihapus",
      status: "success",
    })
  );

  return {
    create,
    remove,
  };
};

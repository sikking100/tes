import { useToast } from '../utils/toast'
import {
  useInfiniteQuery,
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { getProdcutApiInfo, ProductTypes, ResPaging } from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";
import React from "react";

const key = "product";
const keyHistory = "product-history";
const keyBranch = "product-branch";

type ReqCreate = ProductTypes.CreateProduct & {
  t: "create" | "update";
};

type ReqFindProduct = Omit<ProductTypes.ReqProductFind, "limit">;

export const useGetProduct = (r: ReqFindProduct) => {
  const queryClient = useQueryClient();
  const [page, setPage] = React.useState(1);
  const [limit, setLimit] = React.useState(20);
  const [q, setQ] = React.useState("");

  const byPaging = asyncHandler(async () => {
    let res: ProductTypes.Product[] | null = null;
    if (r.branchId) {
      const v = await getProdcutApiInfo().findProductBranch({
        ...r,
        page,
        limit,
      });
      res = v.items;
    } else {
      res = await getProdcutApiInfo().find({
        page,
        limit,
        search: q,
        branchId: r.branchId || "",
        brandId: r.brandId || "",
        categoryId: r.categoryId || "",
        team: r.team || "",
        salesId: r.salesId || "",
      });
    }

    return res;
  });
  const query = useQuery<ProductTypes.Product[], Error>(
    [key, page, limit, q, r],
    byPaging
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data) {
      queryClient.prefetchQuery([keyBranch, page, limit, q, r], byPaging);
    }
  }, [query.data, query.isPreviousData, queryClient, page, limit, q, r]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    setQ,
    page,
  };
};

export const useGetProductBranch = () => {
  const queryClient = useQueryClient();
  const [querys, setQuerys] = React.useState<ProductTypes.ReqProductFind>({
    page: 1,
    limit: 20,
    branchId: "",
    brandId: "",
    categoryId: "",
    search: "",
    salesId: "",
    sort: undefined,
    team: "",
  });

  const onSetQuerys = (r: ReqFindProduct) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...r,
      };
    });
  };

  const onSetPage = (page: number) => {
    setQuerys((prev) => {
      return {
        ...prev,
        page,
      };
    });
  };

  const find = asyncHandler(async () => {
    const res = await getProdcutApiInfo().findProductBranch(querys);
    return res;
  });

  const query = useQuery<ResPaging<ProductTypes.Product>, Error>(
    [keyBranch, querys],
    find
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([keyBranch, querys], find);
    }
  }, [query.data, query.isPreviousData, queryClient, querys]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuerys,
    querys,
    onSetPage,
  };
};

export const useGetProductInfiniteBranch = () => {
  const [querys, setQuerys] = React.useState<ProductTypes.ReqProductFind>({
    page: 1,
    limit: 20,
    branchId: "",
    brandId: "",
    categoryId: "",
    search: "",
    salesId: "",
    sort: undefined,
    team: "",
  });

  const onSetQuerys = (r: ReqFindProduct) => {
    setQuerys((prev) => {
      return {
        ...prev,
        ...r,
      };
    });
  };

  const onSetPage = (page: number) => {
    setQuerys((prev) => {
      return {
        ...prev,
        page,
      };
    });
  };

  const find = asyncHandler(async (pageParam: number) => {
    // console.log("page", pageParam);
    const page = pageParam || 1;
    const res = await getProdcutApiInfo().findProductBranch({
      ...querys,
      page: page,
    });
    return res;
  });

  const query = useInfiniteQuery<ResPaging<ProductTypes.Product>, Error>({
    queryKey: [keyBranch, querys],
    queryFn: ({ pageParam }) => find(pageParam),
    getNextPageParam: (lastPage, allPages) => {
      const nextPage = lastPage.next;
      return nextPage;
    },
    retryOnMount: true,
  });

  console.log("query.data?.pages", query.data?.pages);

  const mP = query.data?.pages.map((pr) => {
    if (pr.next === Number(querys.page) + 1) {
      return pr.items;
    }
    return pr.items;
  })[0];

  return {
    data: mP!,
    hasNextPage: query.hasNextPage,
    isFetchingNextPage: query.isFetchingNextPage,
    fetchNextPage: query.fetchNextPage,
    isLoading: query.isLoading,
    error: query.error?.message,
    onSetQuerys,
    querys,
    onSetPage,
  };
};

export const useGetProductHistory = (r: ProductTypes.RFindProductBranch) => {
  const queryClient = useQueryClient();
  const [page, setPage] = React.useState(1);
  const [q, setQ] = React.useState("");

  const find = asyncHandler(async () => {
    const res = await getProdcutApiInfo().findProductHistory({
      ...r,
      limit: 20,
      page,
      search: q,
    });
    return res;
  });

  const query = useQuery<ResPaging<ProductTypes.HistoryQty>, Error>(
    [keyHistory, page, q, r.branchId],
    find
  );

  React.useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery([keyHistory, page, q, r.branchId], find);
    }
  }, [query.data, query.isPreviousData, page, queryClient, q, r.branchId]);

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
    setPage,
    page,
    setQ,
  };
};

export const useGetProductById = (id: string) => {
  const query = useQuery<ProductTypes.Product, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getProdcutApiInfo().findById(id);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetProductBranchById = (branchId: string) => {
  const query = useQuery<ProductTypes.Product, Error>(
    [keyBranch, branchId],
    asyncHandler(async () => {
      const res = await getProdcutApiInfo().findProductBranchById(branchId);
      return res;
    })
  );

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetProductHistoryById = (id: string) => {
  const query = useQuery<ProductTypes.HistoryQty, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getProdcutApiInfo().findHistoryById(id);
      return res;
    })
  );

  return {
    data: query.error ? undefined : query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useProdcut = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  const create = useMutation<ProductTypes.Product, Error, ReqCreate>(
    asyncHandler(async (req) => {
      const res = await getProdcutApiInfo().create(req);
      return res;
    }),
    toasts({
      title: "Produk",
      description: `Produk berhasil ditambahkan`,
      status: "success",
    })
  );

  const update = useMutation<ProductTypes.Product, Error, ReqCreate>(
    asyncHandler(async (req) => {
      const res = await getProdcutApiInfo().create(req);
      return res;
    }),
    toasts({
      title: "Produk",
      description: `Produk berhasil diperbarui`,
      status: "success",
    })
  );

  const remove = useMutation<ProductTypes.Product, Error, string>(
    asyncHandler(async (id) => {
      const res = await getProdcutApiInfo().delete(id);
      return res;
    }),
    toasts({
      title: "Produk",
      description: "Produk berhasil dihapus",
      status: "success",
    })
  );

  return {
    create,
    remove, update
  };
};

export const useProdcutBranch = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key: keyBranch, queryClient, toast });

  const createProductPrice = useMutation<
    ProductTypes.Product,
    Error,
    ProductTypes.ProductPrice
  >(
    asyncHandler(async (req) => {
      const res = await getProdcutApiInfo().createProductPrice(req);
      return res;
    }),
    toasts({
      title: "Produk",
      description: "Harga Produk berhasil ditambahkan",
      status: "success",
    })
  );

  const createProductBranch = useMutation<
    ProductTypes.Product,
    Error,
    ProductTypes.CrateProductBranch
  >(
    asyncHandler(async (req) => {
      const res = await getProdcutApiInfo().createProductInBranch(req);
      return res;
    }),
    toasts({
      title: "Produk",
      description: "Produk Produk berhasil ditambahkan",
      status: "success",
    })
  );

  const addQtyProduct = useMutation<void, Error, ProductTypes.CreateQty>(
    asyncHandler(async (req) => {
      await getProdcutApiInfo().addQtyProduct(req);
    }),
    toasts({
      title: "Stok",
      description: "Stok berhasil ditambahkan",
      status: "success",
    })
  );

  const transferQty = useMutation<void, Error, ProductTypes.CreateTransferQty>(
    asyncHandler(async (req) => {
      await getProdcutApiInfo().transferQty(req);
    }),
    toasts({
      title: "Stok",
      description: "Transfer Stok berhasil",
      status: "success",
    })
  );

  const updateVisible = useMutation<ProductTypes.Product, Error, string>(
    asyncHandler(async (productId) => {
      const res = await getProdcutApiInfo().updateVisibleProcutInBrancb(
        productId
      );
      return res;
    }),
    toasts({
      title: "Stok",
      description: "Visible berhasil diubah",
      status: "success",
    })
  );

  return {
    // createProductPrice,
    transferQty,
    addQtyProduct,
    updateVisible,
    createProductBranch,
  };
};

export const useGetProductSales = (branchId: string) => {
  const find = asyncHandler(async () => {
    const res = await getProdcutApiInfo().findSalesProductInBranch(branchId);
    return res;
  });

  const query = useQuery<ProductTypes.SalesProduct[], Error>(
    ["sales-prodcut", branchId],
    find
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useProductSales = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key: "sales-prodcut", queryClient, toast });

  const updateProductSales = useMutation<
    void,
    Error,
    ProductTypes.UpdateSalesProduct
  >(
    asyncHandler(async (req) => {
      await getProdcutApiInfo().updateSalesProduct(req);
    }),
    toasts({
      title: "Stok",
      description: "Berhasil menambahkan sales ke produk",
      status: "success",
    })
  );

  return {
    updateProductSales,
  };
};

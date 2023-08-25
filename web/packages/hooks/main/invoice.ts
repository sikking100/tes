import { useToast } from '../utils/toast'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  CompletePayment,
  getInvoiceApiInfo,
  Invoice,
  InvoiceReport,
  ReqPageInvoice,
  ReqReportInvoice,
  ResPaging,
} from "apis";
import { asyncHandler } from "../utils/async";
import { useAlert } from "../utils/on-alert";
import { useEffect, useState } from "react";

const key = "invoice";

type RFindInvoice = Omit<ReqPageInvoice, "page" | "limit" | "search">;

export const useGetInvoice = (r: RFindInvoice) => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(20);
  const [q, setQ] = useState("");

  const find = asyncHandler(async () => {
    if (r.orderId) {
      const res = await getInvoiceApiInfo().findInvoiceByIdOrder(r.orderId);
      const transform: ResPaging<Invoice> = {
        back: null,
        next: null,
        items: res,
        limit: 1,
      };
      return transform;
    }
    const res = await getInvoiceApiInfo().find({
      page,
      limit,
      search: q,
      branchId: r.branchId,
      paymentMethod: r.paymentMethod,
      regionId: r.regionId,
      type: r.type,
      userid: r.userid,
    });
    return res;
  });

  const query = useQuery<ResPaging<Invoice>, Error>(
    [
      key,
      page,
      limit,
      q,
      r.branchId,
      r.paymentMethod,
      r.regionId,
      r.type,
      r.userid,
      r.orderId,
    ],
    find
  );

  useEffect(() => {
    if (!query.isPreviousData && query.data?.next) {
      queryClient.prefetchQuery(
        [
          key,
          page,
          limit,
          q,
          r.branchId,
          r.paymentMethod,
          r.regionId,
          r.type,
          r.userid,
          r.orderId,
        ],
        find
      );
    }
  }, [query.data, query.isPreviousData, page, queryClient, limit, q, { ...r }]);

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

export const useGetInvoiceById = (id: string) => {
  const query = useQuery<Invoice, Error>(
    [key, id],
    asyncHandler(async () => {
      const res = await getInvoiceApiInfo().findById(id);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetInvoiceByOrderId = (id: string) => {
  const query = useQuery<Invoice[], Error>(
    [key, id, "order"],
    asyncHandler(async () => {
      const res = await getInvoiceApiInfo().findInvoiceByIdOrder(id);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useGetInvoiceReport = (q: ReqReportInvoice) => {
  const query = useQuery<InvoiceReport[], Error>(
    ["invoice-report", q],
    asyncHandler(async () => {
      const res = await getInvoiceApiInfo().findReportInvoice(q);
      return res;
    })
  );

  return {
    data: query.data!,
    isLoading: query.isLoading,
    error: query.error?.message,
  };
};

export const useInvoice = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const toasts = useAlert({ key, queryClient, toast });

  const createPayment = useMutation<Invoice, Error, string>(
    asyncHandler(async (req) => {
      const res = await getInvoiceApiInfo().createPayment(req);
      return res;
    }),
    toasts({
      title: "Bantuan",
      description: "Invoice berhasil dibuat",
    })
  );

  const completePayment = useMutation<Invoice, Error, CompletePayment>(
    asyncHandler(async (req) => {
      const res = await getInvoiceApiInfo().completePayment(req);
      return res;
    }),
    toasts({
      title: "Bantuan",
      description: "Pembayaran berhasil diterima",
    })
  );

  return {
    createPayment,
    completePayment,
  };
};

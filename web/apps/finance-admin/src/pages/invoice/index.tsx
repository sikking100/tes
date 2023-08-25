import React from "react";
import { deliveryService, invoiceService, store } from "hooks";
import { Eroles, Invoice, EPaymentMethod, typeInvoice } from "apis";
import {
  ButtonTooltip,
  Icons,
  Modals,
  PText,
  PagingButton,
  Root,
  SearchInput,
  Shared,
  Tables,
  TabsComponent,
  Types,
  entity,
} from "ui";
import {
  Box,
  Divider,
  HStack,
  IconButton,
  SimpleGrid,
  TabPanel,
  Text,
} from "@chakra-ui/react";
import { dataListOrder } from "~/navigation";
import { Link } from "react-router-dom";

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <Root appName="Finance" items={dataListOrder} backUrl={"/"} activeNum={3}>
    {children}
  </Root>
);

export const TextTitle: React.FC<{ title: string; val: React.ReactNode }> = ({
  title,
  val,
}) => (
  <Box>
    <Text fontWeight={"semibold"}>{title}</Text>
    <Text as={"span"} fontSize={"sm"}>
      {val}
    </Text>
  </Box>
);

const DetailInvoice: React.FC<{
  isOpen: boolean;
  setOpen: (v: boolean) => void;
  data: Invoice;
}> = ({ isOpen, setOpen, data }) => {
  const setClose = () => setOpen(false);

  return (
    <Modals isOpen={isOpen} setOpen={setClose} title="Detail Invoice">
      <Text fontWeight={"bold"}>Invoice</Text>
      <Divider />

      <SimpleGrid columns={2} mt={2} gap={3}>
        <HStack>
          <TextTitle title="ID Invoice" val={<Text>{data.id}</Text>} />
        </HStack>
        <TextTitle
          title="Jumlah Pembayaran"
          val={<Text>{Shared.formatRupiah(`${data.price}`)}</Text>}
        />
        <TextTitle title="Tujuan" val={<Text>{data.destination}</Text>} />
        <TextTitle
          title="Metode Pembayaran"
          val={<Text>{entity.paymentMethod(Number(data.paymentMethod))}</Text>}
        />
        <TextTitle
          title="Status"
          val={<Text>{entity.statusInvoice(data.status)}</Text>}
        />
        <TextTitle
          title="Tanggal Pembayaran"
          val={<Text>{Shared.FormatDateToString(data.paidAt)}</Text>}
        />
        <Link
          target="_blank"
          to={`/invoice-print?idOrder=${data.id}&idInvoice=${data.id}`}
        >
          <IconButton
            aria-label="icon print"
            icon={<Icons.IconPrint color="#000" />}
            // onClick={onPrint}
          />
        </Link>
        {/* {data.delivery.status === 7 &&
        i.status === 3 &&
        data.paymentMethod === 0 &&
        data.status !== 2 ? (
          <Buttons
            label='Terima Setoran'
            bg={'red.100'}
            w={'200px'}
            mt={3}
            onClick={() => {
              setOpensInvoice(true)
              setInvoiceId(i.id)
            }}
            isLoading={paidInvoice.isLoading}
          />
        ) : null} */}
      </SimpleGrid>
    </Modals>
  );
};

const InvoicePages = () => {
  const tabList = ["SEMUA", "TRANSFER", "COD", "TOP"];
  const admin = store.useStore((v) => v.admin);
  const [orderId, setOrderId] = React.useState("");
  const [paymentMethod, setpaymentMethod] = React.useState<
    EPaymentMethod | undefined
  >(undefined);
  const { data, error, isLoading, page, setPage } =
    invoiceService.useGetInvoice({
      branchId:
        admin?.roles === Eroles.BRANCH_FINANCE_ADMIN
          ? admin.location.id
          : undefined,
      paymentMethod,
      orderId: orderId,
      type: typeInvoice.HISTORY,
    });
  const { column, isOpen, selectData, setOpen } = columns();

  return (
    <Wrap>
      {isOpen && selectData && (
        <DetailInvoice data={selectData} isOpen={isOpen} setOpen={setOpen} />
      )}
      <TabsComponent TabList={tabList} defaultIndex={0}>
        {tabList.map((v) => (
          <TabPanel
            px={0}
            key={v}
            onClick={() => {
              if (v === "SEMUA") {
                setpaymentMethod(undefined);
              }
              if (v === "TRANSFER") {
                setpaymentMethod(EPaymentMethod.TRA);
              }
              if (v === "COD") {
                setpaymentMethod(EPaymentMethod.COD);
              }
              if (v === "TOP") {
                setpaymentMethod(EPaymentMethod.TOP);
              }
            }}
          >
            <SearchInput
              onChange={(e) => setOrderId(e.target.value)}
              placeholder="Ketik ID Pesanan"
            />
            {error ? (
              <PText label={error} />
            ) : (
              <Tables
                isLoading={isLoading}
                columns={column}
                data={data ? data.items : []}
                usePaging={true}
                useTab={true}
              />
            )}
          </TabPanel>
        ))}
      </TabsComponent>

      <PagingButton
        page={Number(page)}
        nextPage={() => setPage(Number(page) + 1)}
        prevPage={() => setPage(Number(page) - 1)}
        disableNext={data?.next === null}
      />
    </Wrap>
  );
};

const columns = () => {
  const [selectData, setSelectData] = React.useState<Invoice>();
  const [selectIdOrder, setSelectIdOrder] = React.useState<string>();
  const [isOpen, setOpen] = React.useState(false);
  const [isOpenOrder, setOpenOrder] = React.useState(false);

  const column: Types.Columns<Invoice>[] = [
    {
      header: "No Invoice",
      render: (v) => <Text>{v.id}</Text>,
    },
    {
      header: "Metode Pembyaran",
      render: (v) => <Text>{entity.paymentMethod(v.paymentMethod)}</Text>,
    },
    {
      header: "Jumlah",
      render: (v) => <Text>{Shared.formatRupiah(String(v.price))}</Text>,
    },
    {
      header: "Status",
      render: (v) => <Text>{entity.statusInvoice(v.status)}</Text>,
    },
    {
      header: "Pelanggan",
      render: (v) => (
        <Box>
          <Text>{v.customer.name}</Text>
          <Text>{v.customer.phone}</Text>
        </Box>
      ),
    },
    {
      header: "Order",
      render: (v) => (
        <Text
          cursor={"pointer"}
          textDecor={"underline"}
          onClick={() => {
            setSelectIdOrder(v.orderId);
            setOpenOrder(true);
          }}
        >
          Lihat Pesanan
        </Text>
      ),
    },
    {
      header: "Aksi",
      render: (v) => {
        return (
          <HStack>
            <ButtonTooltip
              label={"Detail"}
              icon={<Icons.IconDetails color={"gray"} />}
              onClick={() => {
                setOpen(true);
                setSelectData(v);
              }}
            />
          </HStack>
        );
      },
    },
  ];

  return {
    column,
    isOpenOrder,
    selectIdOrder,
    setSelectIdOrder,
    isOpen,
    selectData,
    setOpen,
  };
};
export default InvoicePages;

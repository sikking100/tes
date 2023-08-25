import {
  Accordion,
  AccordionButton,
  AccordionIcon,
  AccordionItem,
  AccordionPanel,
  Box,
  Button,
  Divider,
  Drawer,
  DrawerBody,
  DrawerCloseButton,
  DrawerContent,
  DrawerFooter,
  DrawerHeader,
  DrawerOverlay,
  HStack,
  SimpleGrid,
  Stack,
  Text,
} from "@chakra-ui/react";
import {
  ButtonForm,
  Buttons,
  FormControlNumber,
  FormControlNumbers,
  FormControls,
  LoadingForm,
  Modals,
  PText,
  Shared,
  StackAvatar,
  Tables,
  Timelines,
  Types,
  entity,
} from "ui";
import { Link as RouterLink } from "react-router-dom";
import { deliveryService, invoiceService, orderService } from "hooks";
import {
  CompletePayment,
  EPaymentMethod,
  Invoice,
  ProductOrder,
  StatusDelivery,
  StatusInvoice,
} from "apis";
import React from "react";
import { useForm } from "react-hook-form";
import { FormatDateToString, formatRupiah } from "ui/src/utils/shared";
import { TextTitle } from "../invoice";

interface Props {
  isOpen: boolean;
  setOpen: (v: boolean) => void;
  idOrder: string;
}

export const DetailOrder: React.FC<Props> = ({ isOpen, setOpen, idOrder }) => {
  const { data, error, isLoading } = orderService.useGetOrderById(idOrder);
  const {
    data: invoiceArr,
    error: invoiceErrorArr,
    isLoading: invoiceLoadingArr,
  } = invoiceService.useGetInvoiceByOrderId(`${idOrder}`);
  const {
    data: invoice,
    error: invoiceError,
    isLoading: invoiceLoading,
  } = invoiceService.useGetInvoiceById(`${data?.invoiceId}`);
  const {
    data: delivery,
    error: deliveryError,
    isLoading: deliveryLoading,
  } = deliveryService.useGetDeliveryOrderId(`${idOrder}`);
  const { completePayment } = invoiceService.useInvoice();
  const columnsProduct = columnsListProduct();
  const onClose = () => setOpen(false);
  const isLoadings = (): boolean => {
    return isLoading || invoiceLoading || deliveryLoading;
  };
  const isErrors = (): string => {
    return error || invoiceError || deliveryError || "";
  };
  const [historyInvoice, setHistoryInvoice] = React.useState<boolean>(false);

  const [openInvoiceCange, setInoviceCange] = React.useState<boolean>(false);

  const [openModalConfir, setOpenModalConfir] = React.useState<boolean>(false);

  return (
    <Modals isOpen={isOpen} setOpen={onClose} size="6xl" title="Detail Pesanan">
      {isErrors() ? (
        <PText label={isErrors()} />
      ) : isLoadings() ? (
        <LoadingForm />
      ) : (
        <Box rounded={"lg"} shadow={"none"} fontSize={"sm"}>
          {historyInvoice && invoiceArr && (
            <HistoryInvoiceCreate
              data={invoiceArr}
              isOpen={historyInvoice}
              setOpen={setHistoryInvoice}
            />
          )}

          {openInvoiceCange && invoiceArr && (
            <HistoryInvoiceCreatePaid
              isOpen={openInvoiceCange}
              setOpen={setInoviceCange}
              data={invoiceArr}
              id={invoice.id}
            />
          )}

          {openModalConfir && (
            <ModalConfir
              id={invoice.id}
              isOpen={openModalConfir}
              setOpen={setOpenModalConfir}
              paid={Number(invoice.price) - Number(invoice.paid)}
              onClose={setOpen}
            />
          )}

          <Accordion defaultIndex={[0]} allowMultiple>
            {/* INVOICE */}
            <AccordionItem p={0}>
              <AccordionButton py={2} px={0}>
                <Box as="span" flex="1" textAlign="left">
                  Invoice
                </Box>
                <AccordionIcon />
              </AccordionButton>
              <AccordionPanel px={0}>
                <SimpleGrid columns={3} mt={2} gap={1}>
                  <TextTitle
                    title="ID Invoice"
                    val={<Text>{invoice?.id}</Text>}
                  />
                  <TextTitle
                    title="Jumlah Tagihan"
                    val={<Text>{Shared.formatRupiah(`${invoice.price}`)}</Text>}
                  />
                  <TextTitle
                    title="Tujuan"
                    val={<Text>{invoice?.destination}</Text>}
                  />
                  <TextTitle
                    title="Metode Pembayaran"
                    val={
                      <Text>
                        {entity.paymentMethod(Number(invoice?.paymentMethod))}
                      </Text>
                    }
                  />
                  <TextTitle
                    title="Status"
                    val={<Text>{entity.statusInvoice(invoice.status)}</Text>}
                  />
                  <TextTitle
                    title="Tanggal Pembayaran"
                    val={
                      <Text>{Shared.FormatDateToString(invoice.paidAt)}</Text>
                    }
                  />
                </SimpleGrid>
                <SimpleGrid columns={4} mt={2} gap={1}>
                  {invoice.paymentMethod !== EPaymentMethod.TRA &&
                  invoice.paymentMethod !== EPaymentMethod.COD ? (
                    <Buttons
                      label="Pembayaran"
                      mt={4}
                      isDisabled={
                        invoice.status === StatusInvoice.PAID ||
                        invoice.status === StatusInvoice.APPLY
                      }
                      isLoading={completePayment.isLoading}
                      onClick={() => setInoviceCange(true)}
                    />
                  ) : null}

                  {invoice.paymentMethod === EPaymentMethod.COD &&
                  delivery !== undefined &&
                  delivery.find((v) => v.id === data.deliveryId) !==
                    undefined &&
                  delivery.find((v) => v.id === data.deliveryId)?.status ===
                    StatusDelivery.COMPLETE ? (
                    <Buttons
                      label="Terima Pembayaran"
                      mt={4}
                      isDisabled={
                        invoice.status === StatusInvoice.PAID ||
                        invoice.status === StatusInvoice.APPLY
                      }
                      isLoading={completePayment.isLoading}
                      onClick={() => {
                        setOpenModalConfir(true);
                      }}
                    />
                  ) : null}

                  {invoice.status === StatusInvoice.APPLY ||
                  invoice.status === StatusInvoice.PENDING ? null : (
                    <Button
                      mt={4}
                      bg={"red.200"}
                      fontSize={"sm"}
                      onClick={() => {
                        setHistoryInvoice(true);
                      }}
                    >
                      Riwayat Pembayaran
                    </Button>
                  )}
                </SimpleGrid>
                <HStack justify={"space-between"}>
                  <Box w={"80%"}></Box>

                  <Button
                    target={`_blank`}
                    mt={4}
                    bg={"red.200"}
                    fontSize={"sm"}
                    as={RouterLink}
                    isDisabled={
                      invoice.status === StatusInvoice.CANCEL ||
                      invoice.status === StatusInvoice.APPLY
                    }
                    style={{
                      pointerEvents: `${
                        invoice.status === StatusInvoice.CANCEL ||
                        invoice.status === StatusInvoice.APPLY
                          ? "none"
                          : "auto"
                      }`,
                    }}
                    to={`/invoice-print?orderId=${data.id}&invoiceId=${invoice.id}`}
                  >
                    Cetak Faktur
                  </Button>
                </HStack>
              </AccordionPanel>
            </AccordionItem>
            {/* PRODUK */}
            <AccordionItem p={0}>
              <AccordionButton py={2} px={0}>
                <Box as="span" flex="1" textAlign="left">
                  Detail Produk
                </Box>
                <AccordionIcon />
              </AccordionButton>
              <AccordionPanel px={0}>
                <Box>
                  <Tables
                    isLoading={isLoading}
                    columns={columnsProduct}
                    data={isLoading ? [] : data.product}
                    pageH="100%"
                  />
                </Box>
                <Box experimental_spaceY={1}>
                  <HStack justify={"space-between"} fontWeight={"bold"}>
                    <Text>Ongkos Kirim</Text>
                    <Text>{Shared.formatRupiah(`${data.deliveryPrice}`)}</Text>
                  </HStack>
                  <HStack justify={"space-between"} fontWeight={"bold"}>
                    <Text>Total Pembayaran</Text>
                    <Text>
                      {Shared.formatRupiah(
                        `${data.totalPrice + data.deliveryPrice}`
                      )}
                    </Text>
                  </HStack>
                </Box>
              </AccordionPanel>
            </AccordionItem>
            {/* DELIVERY */}
            <AccordionItem>
              <AccordionButton py={2} px={0}>
                <Box as="span" flex="1" textAlign="left">
                  Pengantaran
                </Box>
                <AccordionIcon />
              </AccordionButton>
              <AccordionPanel px={0}>
                <Timelines data={delivery!} />
              </AccordionPanel>
            </AccordionItem>
          </Accordion>
        </Box>
      )}
    </Modals>
  );
};

interface Histroy {
  isOpen: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: Invoice[];
}

const HistoryInvoiceCreate: React.FC<Histroy> = (props) => {
  return (
    <Drawer
      isOpen={props.isOpen}
      placement="right"
      // initialFocusRef={firstField}
      onClose={() => props.setOpen(false)}
    >
      <DrawerOverlay />
      <DrawerContent>
        <DrawerCloseButton />
        <DrawerHeader borderBottomWidth="1px">Riwayat Pembayaran</DrawerHeader>

        <DrawerBody>
          {props.data.map((d, key) => (
            <Stack spacing="4px">
              <TextTitle
                title={entity.statusInvoice(d.status)}
                val={<Text>{Shared.FormatDateToString(d.paidAt)}</Text>}
              />
              <TextTitle
                title="TOTAL DIBAYAR"
                val={<Text>{Shared.formatRupiah(`${d.paid}`)}</Text>}
              />
              <Divider />
            </Stack>
          ))}
        </DrawerBody>
      </DrawerContent>
    </Drawer>
  );
};

interface HistroyCreate {
  isOpen: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: Invoice[];
  id: string;
}

const HistoryInvoiceCreatePaid: React.FC<HistroyCreate> = (props) => {
  const {
    register,
    control,
    setValue,
    reset,
    getValues,
    formState,
    watch,
    handleSubmit,
  } = useForm<CompletePayment>();
  const { completePayment } = invoiceService.useInvoice();

  const onCreate = async (req: CompletePayment) => {
    const reqCarete: CompletePayment = {
      id: props.id,
      paid: Number(req.paid),
    };
    await completePayment.mutateAsync(reqCarete);
  };
  return (
    <Drawer
      isOpen={props.isOpen}
      placement="right"
      onClose={() => props.setOpen(false)}
    >
      <DrawerOverlay />
      <DrawerContent>
        <DrawerCloseButton />
        <DrawerHeader borderBottomWidth="1px">Pembayaran Invoice</DrawerHeader>
        <form onSubmit={handleSubmit(onCreate)}>
          <DrawerBody>
            {props.data.map((d, key) => (
              <Stack spacing="4px">
                <TextTitle
                  title="TOTAL TELAH DIBAYAR"
                  val={<Text>{Shared.formatRupiah(`${d.paid}`)}</Text>}
                />
                <Divider />
              </Stack>
            ))}
            <br />

            <FormControlNumbers
              control={control}
              label="paid"
              register={register}
              title={"Masukan Nilai Pembayaran"}
              required={"Pembayaran tidak boleh kosong"}
              type="number"
            />
          </DrawerBody>

          <DrawerFooter borderTopWidth="1px">
            <Button variant="outline" mr={3} color={"red.500"} type="submit">
              Terima Pembayaran
            </Button>
          </DrawerFooter>
        </form>
      </DrawerContent>
    </Drawer>
  );
};

const columnsListProduct = () => {
  const column: Types.Columns<ProductOrder>[] = [
    {
      header: "Nama Produk",
      render: (v) => <StackAvatar imageUrl={v.imageUrl} name={v.name} />,
    },
    {
      header: "Harga",
      render: (v) => <Text>{Shared.formatRupiah(`${v.unitPrice}`)}</Text>,
    },
    {
      header: "Jumlah",
      render: (v) => <Text>{v.qty}</Text>,
    },
    {
      header: "Total",
      render: (v) => (
        <Text>{Shared.formatRupiah(`${v.unitPrice * v.qty}`)}</Text>
      ),
    },
    {
      header: "Diskon",
      render: (v) => <Text>{Shared.formatRupiah(`${v.discount}`)}</Text>,
    },
    {
      header: "Subtotal",
      render: (v) => {
        return <Text>{Shared.formatRupiah(`${v.totalPrice}`)}</Text>;
      },
    },
  ];

  return column;
};

interface ModalConfir {
  id: string;
  paid: number;
  isOpen: boolean;
  onClose: (v: boolean) => void;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
}

const ModalConfir: React.FC<ModalConfir> = (props) => {
  const { completePayment } = invoiceService.useInvoice();

  return (
    <Modals isOpen={props.isOpen} setOpen={props.setOpen}>
      <Text fontWeight={"bold"} fontSize={"lg"}>
        Konfirmasi Pembayaran
      </Text>
      <Text>
        <b>ID Invoice</b> : {props.id}
      </Text>
      <Text>
        <b>Jumlah Tagihan</b> : {formatRupiah(`${props.paid}`)}
      </Text>

      <DrawerFooter borderTopWidth="1px">
        <Button
          variant="outline"
          mr={3}
          color={"red.500"}
          onClick={async () => {
            const reqCarete: CompletePayment = {
              id: props.id,
              paid: Number(props.paid),
            };

            props.setOpen(false);
            // console.log(reqCarete)
            await completePayment.mutateAsync(reqCarete);
            props.onClose(false);
          }}
        >
          Terima Pembayaran
        </Button>
      </DrawerFooter>
    </Modals>
  );
};

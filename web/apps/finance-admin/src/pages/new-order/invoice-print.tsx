import React from "react";
import {
  Avatar,
  Box,
  Center,
  Flex,
  HStack,
  Heading,
  Image,
  ListItem,
  OrderedList,
  Spacer,
  Table,
  Tbody,
  Td,
  Text,
  Th,
  Thead,
  Tr,
  Grid,
  GridItem,
  SimpleGrid,
  Tfoot,
} from "@chakra-ui/react";
// import { PDFDownloadLink, Document, Page } from '@react-pdf/renderer'
import styled from "@emotion/styled";
import { Buttons, Inputs, LoadingForm, Shared, entity } from "ui";
import { useSearchParams } from "react-router-dom";
import {
  deliveryService,
  invoiceService,
  orderService,
} from "~/../../../packages/hooks";

const MediaPrint = styled("div")`
  @media print {
    .hide-on-print {
      display: none;
    }
    html,
    body {
      size: A4;
      border: initial;
      font-size: 12px;
      font-family: Times New Roman;
    }
  }
`;

const ContencInv = styled("div")`
  table {
    page-break-inside: avoid;
    font-family: Times New Roman;
  }
  width: 800px;
  margin: auto;
  padding: 20px 0px 0px;
  @media print {
    font-family: Times New Roman;
    size: A4;
    border: initial;
    font-size: 12px;
    padding-left: 0px;
    margin-left: 0px;
  }
`;

interface propsInvoicePrint {
  orderId: string;
  invoiceId: string;
}

const InvoicePrint: React.FC<propsInvoicePrint> = (props) => {
  const { data, error, isLoading } = orderService.useGetOrderById(
    props.orderId
  );
  const {
    data: invoice,
    error: invoiceError,
    isLoading: invoiceLoading,
  } = invoiceService.useGetInvoiceById(props.invoiceId);
  const {
    data: delivery,
    error: deliveryError,
    isLoading: deliveryLoading,
  } = deliveryService.useGetDeliveryOrderId(props.orderId);

  // const getOngkir = () => {
  //   let numOngkir = 0
  //   const d = data?.product
  //     .map((i) => {
  //       const dd = i.price - i.discount
  //       const ddd = i.qty * dd
  //       return ddd
  //     })
  //     .reduce((partialSum, a) => partialSum + a, 0)
  //   numOngkir = Number(data?.price) - Number(d)
  //   return numOngkir
  // }

  // perubahan harga produk
  // const newPriceDiscon = (p: number, l: number, discon: number, qty: number) => {
  //   let d = p

  //   if (additionalDiscount > 0) {
  //     console.log('manipulasi price')
  //     let newRate = additionalDiscount / l
  //     let price = p * qty + newRate
  //     let dq = discon * qty

  //     d = price - dq
  //   } else {
  //     let price = p * qty
  //     let dis = discon * qty
  //     d = price - dis
  //   }
  //   // console.log(d)
  //   return d
  // }

  const formatRupiah = (angka: string): string => {
    const prefix = " ";
    const number_string = angka.replace(/[^,\d]/g, "").toString(),
      split = number_string.split(","),
      sisa = split[0].length % 3,
      ribuan = split[0].substr(sisa).match(/\d{3}/gi);
    let rupiah = split[0].substr(0, sisa);

    if (ribuan) {
      const separator = sisa ? "." : "";
      rupiah += separator + ribuan.join(".");
    }

    rupiah = split[1] != undefined ? rupiah + "," + split[1] : rupiah;
    return prefix == undefined ? rupiah : rupiah ? "  " + rupiah : "";
  };

  const formatPPn = (angka: number): number => {
    const percentage = 11 / 100;
    let hasil = angka * percentage;
    // return Number(Math.trunc(hasil));
    return Number(hasil.toFixed(0));
  };

  const formatPriceNoPPn = (totalPrice: number, qty: number): number => {
    let hasil = totalPrice / 1.11;
    let t = Number(hasil) / qty;
    // return Number(Math.trunc(t));
    return Number(t.toFixed(0));
  };

  const formatNumberPrice = (angka: string): string => {
    const prefix = "";
    const number_string = angka.replace(/[^,\d]/g, "").toString(),
      split = number_string.split(","),
      sisa = split[0].length % 3,
      ribuan = split[0].substr(sisa).match(/\d{3}/gi);
    let rupiah = split[0].substr(0, sisa);

    if (ribuan) {
      const separator = sisa ? "." : "";
      rupiah += separator + ribuan.join(".");
    }

    rupiah = split[1] != undefined ? rupiah + "," + split[1] : rupiah;
    return prefix == undefined ? rupiah : rupiah ? rupiah : "";
  };

  console.log(data);

  return isLoading || invoiceLoading || deliveryLoading ? (
    <LoadingForm />
  ) : (
    <MediaPrint>
      <Flex
        bg={"white.100"}
        shadow={"0 -1px 7px 0 rgb(0 0 0 / 15%)"}
        minH={"7vh"}
        alignItems={"center"}
        padding={"8px"}
        justifyContent={"end"}
        className="hide-on-print"
      >
        <Box w="auto">
          <Buttons
            className="hide-on-print"
            textAlign={"center"}
            label="Cetak"
            type="submit"
            onClick={() => {
              window.print();
            }}
          />
        </Box>
      </Flex>
      <ContencInv>
        {/* <Flex w={'100%'} maxH={'70px'} h={'50px'} alignItems={'center'}>
          
        </Flex> */}
        <Box>
          <SimpleGrid columns={2} spacing={10}>
            <Image
              className="logo"
              borderRadius={"none"}
              alt="logo"
              src={"/images/favicon.ico"}
              maxW={"48px"}
            />

            <Box
              borderWidth="0.1px"
              borderRadius="md"
              border={"1px solid"}
              borderColor={"black"}
            >
              <table style={{ width: "100%", fontSize: "12px" }}>
                <tr>
                  <th
                    style={{
                      padding: "0.2em",
                      borderRight: "1px solid",
                      borderBottom: "1px solid",
                      textAlign: "center",
                      borderTop: "0px",
                    }}
                  >
                    <Text fontSize={"12px"} fontWeight={"semibold"}>
                      Tgl / <i style={{ fontWeight: "normal" }}>Date</i>
                    </Text>
                  </th>
                  <th
                    style={{
                      fontSize: "12px",
                      borderTop: "0px",
                      textAlign: "center",
                      padding: "0.2em",
                      borderBottom: "1px solid",
                    }}
                  >
                    <Text fontWeight={"normal"} fontSize={"12px"}>
                      {Shared.FormatDateToString(invoice.paidAt)}
                    </Text>
                  </th>
                </tr>
                <tr>
                  <td
                    style={{
                      textAlign: "center",
                      padding: "0.2em",
                      borderRight: "1px solid",
                    }}
                  >
                    <Text fontSize={"12px"} fontWeight={"semibold"}>
                      No Faktur /
                    </Text>
                    <Text fontSize={"12px"}>
                      <i>Inv. No.</i>
                    </Text>
                  </td>
                  <td style={{ textAlign: "center", padding: "0.2em" }}>
                    <Text fontSize={"12px"}>{invoice.id}</Text>
                  </td>
                </tr>
              </table>
            </Box>
          </SimpleGrid>

          {/* <Spacer /> */}
        </Box>

        <Flex pb={0} pt={8} justifyContent={"center"} alignItems={"center"}>
          <Box
            maxW="sm"
            overflow="hidden"
            w={"44%"}
            maxH={"20vh"}
            marginRight={"12px"}
          >
            <Heading
              as="h6"
              size="lg"
              textAlign={"center"}
              fontWeight={"semibold"}
            >
              Faktur / <i style={{ fontWeight: "normal" }}>Invoice</i>
            </Heading>
          </Box>
        </Flex>
        <Flex alignItems={"start"} marginTop={"10px"}>
          <Box flex="1">
            <Flex>
              <Text fontSize={"12px"} fontWeight={"semibold"}>
                Dijual ke / <i style={{ fontWeight: "normal" }}> Sold to</i>
              </Text>
            </Flex>
            <Box textAlign={"start"}>
              <Text marginTop={"8px"} fontSize={"12px"}>
                {data?.customer?.name}
              </Text>
            </Box>
          </Box>

          <Box flex="1" maxW={"34%"}>
            <Flex>
              <Text fontSize={"12px"} fontWeight={"semibold"}>
                Barang dikirim kepada / <br />{" "}
                <i style={{ fontWeight: "normal" }}>Goods delivered to</i>
              </Text>
            </Flex>

            <Box textAlign={"start"}>
              <Text marginTop={"8px"} fontSize={"12px"}>
                {/* {data?.delivery.address.name} */}
                {data.customer.addressName}
              </Text>
            </Box>
          </Box>
        </Flex>

        <Box fontSize={12} minH={"80px"} pt={"20px"}>
          <Box minH={"74px"}>
            <Flex experimental_spaceX={3} mt={2}>
              <Box w={"25%"} experimental_spaceY={2}>
                <Box gap={1}>
                  <Text fontSize={12} fontWeight={"semibold"}>
                    Id Pesanan /
                  </Text>
                  <Text fontSize={12}>
                    <i>Order Id</i>
                  </Text>
                </Box>
                <Box>
                  <Text fontSize={12}>{data.id}</Text>
                </Box>
              </Box>
              <Box w={"18%"} experimental_spaceY={2}>
                <Box gap={1}>
                  <Text fontSize={12} fontWeight={"semibold"}>
                    Tgl Order /
                  </Text>
                  <Text>
                    <i>Order Date</i>
                  </Text>
                </Box>
                <Box>
                  <Text fontSize={12}>
                    {Shared.FormatDateToString(data?.createdAt)}
                  </Text>
                </Box>
              </Box>
              <Box w={"23%"} experimental_spaceY={2}>
                <Box gap={1}>
                  <Text fontWeight={"semibold"}>No. Langganan /</Text>
                  <Text>
                    <i>Cust. No.</i>
                  </Text>
                </Box>
                <Box>
                  <Text fontSize={12}>{data.customer?.id}</Text>
                </Box>
              </Box>

              <Box w={"17%"} experimental_spaceY={2}>
                <Box>
                  <Text fontWeight={"semibold"}>Lokasi /</Text>
                  <Text>
                    <i>Loc</i>
                  </Text>
                </Box>
                <Box gap={1}>
                  <Text fontSize={12}>{data.branchName}</Text>
                </Box>
              </Box>
              <Box w={"20%"} experimental_spaceY={2}>
                <Box>
                  <Text fontWeight={"semibold"}>Pembayaran /</Text>
                  <Text>
                    <i>Term</i>
                  </Text>
                </Box>
                <Box>
                  <Text fontSize={12}>
                    {entity.paymentMethod(Number(invoice?.paymentMethod))}
                  </Text>
                </Box>
              </Box>
            </Flex>
          </Box>
          <Box h={"auto"} minH={"74px"} pt={"20px"}>
            <Table size="sm" variant={"unstyled"}>
              <Thead>
                <Tr>
                  {[
                    "Nama Produk",
                    "Harga",
                    "PPN",
                    "Diskon",
                    "Jumlah",
                    "Sub Total",
                  ].map((i, key) => (
                    <Th
                      pr={4}
                      pl={key > 0 ? 4 : 0}
                      // textAlign={key > 0 ? "start" : "start"}
                      minW={"10px"}
                      w={key > 0 ? "auto" : "auto"}
                      px={0}
                      key={key}
                    >
                      {i}
                    </Th>
                  ))}
                </Tr>
              </Thead>
              <Tbody>
                {data.product.map((i, k) => (
                  <Tr key={k}>
                    <Td px={0} w={"fit-content"} fontSize={"sm"}>
                      <Box>
                        <Text>
                          {Shared.splitText(i.name, 30)} {i.size}
                        </Text>
                      </Box>
                    </Td>

                    <Td px={0} isNumeric fontSize={"sm"} pr={4} pl={4}>
                      <div
                        style={{
                          display: "flex",
                          justifyContent: "space-between",
                        }}
                      >
                        <span>Rp. </span>
                        <span>
                          {formatRupiah(
                            `${Math.trunc(
                              formatPriceNoPPn(Number(i.totalPrice), i.qty)
                            )}`
                          )}
                        </span>
                      </div>
                    </Td>

                    <Td px={0} fontSize={"sm"} pr={4} pl={4}>
                      <Flex justifyContent={"space-between"}>
                        {/* ppn */}
                        <Box minW={"25%"} textAlign={"start"}>
                          Rp.
                        </Box>
                        <Box minW={"35%"} textAlign={"end"}>
                          {formatRupiah(
                            `${Math.trunc(
                              formatPPn(
                                formatPriceNoPPn(Number(i.totalPrice), i.qty)
                              )
                            )}`
                          )}
                        </Box>
                      </Flex>
                    </Td>
                    <Td px={0} fontSize={"sm"} pr={4} pl={4}>
                      <Flex justifyContent={"space-between"}>
                        <Box minW={"25%"} textAlign={"start"}>
                          Rp.{" "}
                        </Box>
                        <Box minW={"35%"} textAlign={"end"}>
                          {formatRupiah(`${i.discount}`)}
                        </Box>
                      </Flex>
                    </Td>
                    <Td px={0} isNumeric textAlign={"end"} pr={4} pl={4}>
                      {i.qty}
                    </Td>
                    <Td px={0} fontSize={"sm"} pr={4} pl={4}>
                      <Flex justifyContent={"space-between"}>
                        <Box minW={"25%"} textAlign={"start"}>
                          Rp.{" "}
                        </Box>
                        <Box minW={"35%"} textAlign={"end"}>
                          {formatRupiah(`${i.totalPrice}`)}
                        </Box>
                      </Flex>
                    </Td>
                  </Tr>
                ))}
              </Tbody>
              <Tfoot>
                <Tr>
                  <Th></Th>
                  <Th px={0}></Th>
                  <Th px={0} textAlign={"start"} fontSize={"sm"}></Th>
                  <Th px={0} textAlign={"start"} fontSize={"sm"}></Th>
                </Tr>
                <Tr w={"fit-content"}>
                  <Td px={0}>
                    <Text fontSize={"sm"} fontWeight={"semibold"}>
                      Ongkos Kirim / <br />
                      <i style={{ fontWeight: "normal" }}>Shipping cost</i>
                    </Text>
                  </Td>
                  <Td px={0}></Td>
                  <Td px={0}></Td>
                  <Td px={0}></Td>
                  <Td px={0} textAlign={"end"} fontSize={"sm"}></Td>

                  <Td px={0} fontSize={"sm"} pr={4} pl={4}>
                    <Flex justifyContent={"space-between"}>
                      <Box minW={"25%"} textAlign={"start"}>
                        Rp.{" "}
                      </Box>
                      <Box minW={"35%"} textAlign={"end"}>
                        {formatRupiah(String(data.deliveryPrice))}
                      </Box>
                    </Flex>
                  </Td>
                </Tr>
                <Tr w={"fit-content"}>
                  <Td px={0}></Td>
                  <Td px={0}></Td>
                  <Td px={0}></Td>
                  <Td px={0}></Td>

                  <Td px={0} fontSize={"sm"} pr={4} pl={4}>
                    <Text fontSize={"sm"} fontWeight={"semibold"}>
                      TOTAL
                    </Text>
                  </Td>

                  <Td px={0} textAlign={"end"} fontSize={"sm"} pr={4} pl={4}>
                    <Flex justifyContent={"space-between"}>
                      <Box
                        minW={"25%"}
                        textAlign={"start"}
                        fontWeight={"semibold"}
                      >
                        Rp.{" "}
                      </Box>
                      <Box
                        minW={"35%"}
                        textAlign={"end"}
                        fontWeight={"semibold"}
                      >
                        {formatRupiah(`${data.totalPrice}`)}
                      </Box>
                    </Flex>
                  </Td>
                </Tr>
              </Tfoot>
            </Table>
          </Box>
          <Box h={"auto"}>
            <Flex
              w={"100%"}
              minH={"20px"}
              h={"auto"}
              alignItems={"baseline"}
              paddingLeft={"2px"}
              top={"0"}
              position="relative"
            >
              <Box textAlign={"start"} flex="1">
                <OrderedList fontSize="12" fontWeight={"semibold"}>
                  <ListItem>
                    Barang-barang yang sudah dibeli tidak dapat ditukar /
                    dikembalikan.
                  </ListItem>
                  <ListItem>
                    Pembayaran melalui Bank dianggap lunas setelah dicairkan.
                  </ListItem>
                </OrderedList>
                <OrderedList fontSize="12">
                  <ListItem>
                    Goods which have been purchased cannot be exchanged /
                    returned.
                  </ListItem>
                  <ListItem>
                    Payment through bank is treated as settled only after
                    clearing.
                  </ListItem>
                </OrderedList>
              </Box>
            </Flex>
          </Box>
        </Box>
      </ContencInv>
    </MediaPrint>
  );
};

const InvoicePrintPage = () => {
  const [searchParams] = useSearchParams();
  const orderId = searchParams.get("orderId");
  const invoiceId = searchParams.get("invoiceId");

  if (invoiceId === null || orderId === null) return null;
  return <InvoicePrint invoiceId={invoiceId} orderId={orderId} />;
};

export default InvoicePrintPage;

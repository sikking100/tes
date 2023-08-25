import { useEffect, useState } from "react";
import { customersService } from "hooks";
import { getOrderApiInfo } from "apis";
import { LoadingForm, Modals, PText, Shared } from "ui";
import {
  Avatar,
  Box,
  Divider,
  HStack,
  SimpleGrid,
  Text,
} from "@chakra-ui/react";
import { userStore } from "./customer";
import { WrapCustomerApplys } from "./customer-detail-apply";

interface PropsDetailCustomer {
  // isOpen: boolean
  // setOpen: (v: boolean) => void
  customerId: string;
}

const DetailCustomer: React.FC<PropsDetailCustomer> = ({ customerId }) => {
  const [loading, setLoading] = useState(true);
  const [isOpenBusiness, setOpenBusiness] = useState(false);
  const [transactionLast, setTransactionLast] = useState(0);
  const [transaPerMonth, setTransactionPerMonth] = useState(0);
  const user = userStore((v) => v.user);
  const setOpenDetailBusiness = userStore((v) => v.setOpenDetailBusiness);
  const isOpenDetailBusiness = userStore((v) => v.isOpenDetailBusiness);

  const setUser = userStore((v) => v.setUser);
  const setIsApprove = userStore((v) => v.setIsApprove);

  const { data, isLoading, error } =
    customersService.useGetCustomerById(customerId);

  const findTransaction = async () => {
    try {
      const transactionLastMonth =
        await getOrderApiInfo().findTransactionLastMonth({ customerId });
      setTransactionLast(transactionLastMonth);
      const transactionPerMonth =
        await getOrderApiInfo().findTransactionPerMonth({ customerId });
      setTransactionPerMonth(transactionPerMonth);
    } catch (error) {
      console.log(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    findTransaction();
  }, []);

  const onClose = () => setOpenDetailBusiness(false);

  const isLoadings = () => {
    return isLoading || loading;
  };

  const setOpenDetailBusines = () => {
    setOpenBusiness(true);
    setIsApprove(true);
    setUser({
      address: data.business.address,
      creditActual: data.business.credit,
      id: data.id,
      location: data.business.location,
      priceList: data.business.priceList,
      customer: {
        ...data.business.customer,
        imageUrl: data.imageUrl,
      },
      pic: data.business.pic,
      viewer: data.business.viewer,
      creditProposal: data.business.credit,
      tax: data.business.tax,
      transactionLastMonth: transactionLast,
      transactionPerMonth: transaPerMonth,
      userApprover: [],
      type: 0,
      status: 0,
      expiredAt: "",
      team: 0,
    });
  };

  console.log(data);

  return (
    <Modals
      isOpen={isOpenDetailBusiness}
      setOpen={onClose}
      title="Detail Pelanggan"
      size="6xl"
    >
      {error && <PText label={error} />}
      {isLoadings() && <LoadingForm />}
      {data && (
        <>
          {!isOpenBusiness && data.name !== undefined && (
            <HStack align={"start"}>
              <Avatar src={data.imageUrl} name={data.name} size={"2xl"} />
              <SimpleGrid columns={2} gap={5} w="full">
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    ID
                  </Text>
                  <Text textTransform={"capitalize"}>{data.id}</Text>
                  <Divider />
                </Box>
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    Nama
                  </Text>
                  <Text textTransform={"capitalize"}>
                    {data.name.toLowerCase()}
                  </Text>
                  <Divider />
                </Box>
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    Jumlah Transaksi Terakhir
                  </Text>
                  <Text textTransform={"capitalize"}>
                    {Shared.formatRupiah(String(transactionLast))}
                  </Text>
                  <Divider />
                </Box>
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    Email
                  </Text>
                  <Text>{data.email}</Text>
                  <Divider />
                </Box>
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    Nomor HP
                  </Text>
                  <Text textTransform={"capitalize"}>{data.phone}</Text>
                  <Divider />
                </Box>
                <Box w="full">
                  <Text fontSize={"sm"} fontWeight={"bold"}>
                    Jenis Pelanggan
                  </Text>
                  <Text textTransform={"capitalize"}>
                    {data.business ? "Bisnis" : "Walk-In"}
                  </Text>
                  <Divider />
                </Box>
              </SimpleGrid>
            </HStack>
          )}

          {/* BUSINES */}
          {isOpenBusiness && user && <WrapCustomerApplys />}
          {data.business && (
            <Text
              textDecor={"underline"}
              cursor={"pointer"}
              fontWeight={"semibold"}
              onClick={() => {
                if (isOpenBusiness) setOpenBusiness(false);
                else setOpenDetailBusines();
              }}
            >
              {isOpenBusiness ? "Kembali" : "Detail Bisnis"}
            </Text>
          )}
        </>
      )}
    </Modals>
  );
};

export default DetailCustomer;

import React from "react";
import {
  Input,
  Box,
  Divider,
  SimpleGrid,
  Text,
  TabPanel,
  InputGroup,
  InputRightElement,
  IconButton,
  Image,
  useDisclosure,
  Drawer,
  DrawerContent,
  VStack,
  Flex,
  Checkbox,
  Skeleton,
  Spinner,
  HStack,
} from "@chakra-ui/react";
import { GoLocation } from "react-icons/go";
import { useForm } from "react-hook-form";
import {
  ButtonForm,
  FormControlNumber,
  FormControls,
  FormControlsTextArea,
  FormSelects,
  ImagePick,
  MapsPickLocation,
  Modals,
  PText,
  Shared,
  TabsComponent,
  TimeLineApproval,
  Icons,
  useToast,
  entity,
  Images,
} from "ui";
import { customersService, store, useDownloadImage, usePickImage } from "hooks";
import { DayTax, StatusTax, rolesData } from "./const";
import {
  ICustomerCtx,
  ReqTypes,
  onCreate,
  onCreateApply,
  onUpdateBussiness,
  searchsBranch,
  searchsPriceList,
  setMapsProps,
} from "./function";
import { disclousureStore } from "~/store";
import { Branch, PriceList, StatusUserApprover } from "apis";
import { userStore } from "./customer";

const CustomerDetailCtx = React.createContext<ICustomerCtx>({} as ICustomerCtx);

const Wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { register, control, setValue, reset, getValues, formState, watch } =
    useForm<ReqTypes>();

  return (
    <CustomerDetailCtx.Provider
      value={{
        register,
        control,
        setValue,
        reset,
        getValues,
        formState,
        watch,
        isReadOnly: false,
      }}
    >
      {children}
    </CustomerDetailCtx.Provider>
  );
};

const ProfileUsaha = () => {
  const { setValue, register, control, getValues } =
    React.useContext(CustomerDetailCtx);
  const admin = store.useStore((v) => v.admin);
  const isOpenCreate = userStore((v) => v.isOpenCreate);
  const users = userStore((v) => v.users);
  const isApprove = userStore((v) => v.isApprove);
  const [loading, setLoading] = React.useState(true);
  const [loadingPriceList, setLoadingPriceList] = React.useState(true);
  const { preview, onSelectFile, selectedFile, setPreview } = usePickImage();

  const searchPriceList = searchsPriceList();
  const searchBranch = searchsBranch();

  const defaultBranch = async () => {
    const branch = getValues("location.branchName");
    const find = await searchBranch(branch);
    find.map((v) => {
      const branchId = getValues("location.branchId");
      const branch = JSON.parse(v.value) as Branch;
      if (branchId === branch.id) {
        setValue("location_", {
          label: branch.name,
          value: JSON.stringify(branch),
        });
      }
    });
    setLoading(false);

    const price = await searchPriceList();
    price.map((v) => {
      const priceList = getValues("priceList.id");
      const pr = JSON.parse(v.value) as PriceList;
      if (priceList === pr.id) {
        setValue("priceList_", {
          label: pr.name,
          value: JSON.stringify(pr),
        });
      }
    });

    setLoadingPriceList(false);
    if (!isOpenCreate) {
      setPreview(`${getValues().customer.imageUrl}`);
    }

    const fRoles = rolesData.find((v) => v.value === `${getValues("viewer")}`);
    if (fRoles) {
      setValue("roles_", fRoles);
    }
  };

  React.useEffect(() => {
    defaultBranch();
  }, []);

  React.useEffect(() => {
    if (selectedFile) {
      setValue("image_", selectedFile);
    }
  }, [selectedFile]);

  const findAlreadyApprove = () => {
    if (!admin) return;

    const find = getValues().userApprover?.find((v) => v.id === admin.id);
    if (find) return true;
    return false;
  };

  const setMt = React.useMemo(() => {
    if (window.screen.availWidth >= 1920) {
      return {
        w: 320,
        h: 225,
      };
    }
    if (window.screen.availWidth >= 1535) {
      return {
        w: 320,
        h: 225,
      };
    }
    if (window.screen.availWidth >= 1440) {
      return {
        w: 320,
        h: 225,
      };
    }
    if (window.screen.availWidth >= 1366) {
      return {
        w: 320,
        h: 225,
      };
    }

    return {
      w: 300,
      h: 200,
    };
  }, [window.screen.availWidth]);

  return (
    <React.Fragment>
      {getValues() && (
        <>
          <SimpleGrid columns={2} gap={10}>
            <Box experimental_spaceY={3}>
              <>
                {isApprove || !isOpenCreate ? (
                  <Box w={"fit-content"} h={"fit-content"}>
                    <Images
                      label="Foto Usaha"
                      w={setMt.w}
                      h={setMt.h}
                      src={
                        getValues()?.customer?.imageUrl ||
                        "/image-thumbnail.png"
                      }
                      objectFit="cover"
                    />
                  </Box>
                ) : (
                  <Box w={"fit-content"} h={"fit-content"}>
                    <ImagePick
                      title="Foto Usaha"
                      w={setMt.w}
                      h={setMt.h}
                      idImage="foto usaha"
                      imageUrl={preview as string}
                      onChangeInput={(e) => onSelectFile(e.target)}
                    />
                  </Box>
                )}
              </>

              {isApprove ? (
                <VStack align={"start"}>
                  <Text fontWeight={500} fontSize={"sm"}>
                    Nama Usaha
                  </Text>
                  <Input readOnly value={`${users?.name}`} />
                </VStack>
              ) : (
                <FormControls
                  // readOnly={!findAlreadyApprove()}
                  label="customer.name"
                  register={register}
                  title={"Nama Usaha"}
                  required={"Nama tidak boleh kosong"}
                />
              )}

              <FormControls
                readOnly={isApprove}
                label={"customer.address"}
                register={register}
                title={"Alamat Usaha"}
              />
            </Box>
            <Box experimental_spaceY={3}>
              <React.Fragment>
                {!isApprove && !findAlreadyApprove() && (
                  <FormSelects
                    control={control}
                    options={[
                      {
                        label: "FOOD SERVICE",
                        value: "1",
                      },
                      {
                        label: "RETAIL",
                        value: "2",
                      },
                    ]}
                    label={"team_"}
                    placeholder={"Pilih Tim"}
                    required={"Tim tidak boleh kosong"}
                    title={"Tim"}
                  />
                )}

                {findAlreadyApprove() && (
                  <VStack align={"start"}>
                    <Text fontWeight={500} fontSize={"sm"}>
                      Roles
                    </Text>
                    <Input
                      readOnly
                      value={`${
                        getValues("viewer") === 0
                          ? "All"
                          : entity.roles(getValues("viewer"))
                      }`}
                    />
                    <Text fontSize={"sm"} pt={"2px"} color={"red.200"}>
                      * Roles yang dapat melihat bisnis
                    </Text>
                  </VStack>
                )}

                {loadingPriceList ? (
                  <Skeleton height="20px" />
                ) : (
                  <>
                    {isApprove ? (
                      <VStack align={"start"}>
                        <Text fontWeight={500} fontSize={"sm"}>
                          Kategori Harga
                        </Text>
                        <Input
                          readOnly
                          value={`${getValues("priceList.name")}`}
                        />
                      </VStack>
                    ) : (
                      <FormSelects
                        async={true}
                        defaultValue={getValues("priceList_")}
                        control={control}
                        loadOptions={searchPriceList}
                        label={"priceList_"}
                        placeholder={"Pilih Kategori Harga"}
                        required={"Kategori Harga tidak boleh kosong"}
                        title={"Kategori Harga"}
                      />
                    )}
                  </>
                )}

                {loading ? (
                  <Skeleton height="20px" />
                ) : (
                  <FormSelects
                    async={true}
                    defaultValue={getValues("location_")}
                    control={control}
                    loadOptions={searchBranch}
                    label={"location_"}
                    placeholder={"Pilih Lokasi"}
                    required={"Lokasi tidak boleh kosong"}
                    title={"Lokasi"}
                  />
                )}

                {findAlreadyApprove() && (
                  <Box>
                    <FormControlsTextArea
                      label="note_"
                      register={register}
                      title={"Catatan"}
                    />
                  </Box>
                )}
              </React.Fragment>
            </Box>
          </SimpleGrid>
        </>
      )}
    </React.Fragment>
  );
};

const ShippingAddressCard = () => {
  const { setValue, getValues, watch } = React.useContext(CustomerDetailCtx);
  const user = userStore((v) => v.user);
  const isOpenCreate = userStore((v) => v.isOpenCreate);
  const admin = store.useStore((v) => v.admin);
  const [idxMaps, setIdxMaps] = React.useState<setMapsProps>({
    idx: 0,
    type: "shipping",
  });
  const [isOpenMap, setOpenMap] = React.useState(false);
  const address = watch("address");

  const findAlreadyApprove = () => {
    if (!admin) return;

    const find = user?.userApprover?.find(
      (v) =>
        (v.id === admin.id && v.status === StatusUserApprover.APPROVE) ||
        v.status === StatusUserApprover.REJECT
    );
    if (find) return false;
    if (isOpenCreate) return true;
    return true;
  };

  const setMaps = (i: setMapsProps) => {
    if (i.type === "shipping") {
      return (
        <MapsPickLocation
          height="30vh"
          currentLoc={(e) => {
            const newArr = address.map((obj, idx) => {
              if (idx === i.idx) {
                return {
                  lngLat: [e.lat, e.lng],
                  name: e.address,
                };
              }
              return obj;
            });

            setValue("address", newArr);
          }}
        />
      );
    }

    return <></>;
  };

  return (
    <Box minH={"420px"} maxH={"420px"} overflow={"auto"}>
      {isOpenMap ? (
        <Box mb={1}>{setMaps({ idx: idxMaps.idx, type: idxMaps.type })}</Box>
      ) : null}
      {findAlreadyApprove() && (
        <Text
          textDecor={"underline"}
          cursor={"pointer"}
          textAlign={"right"}
          fontWeight={500}
          onClick={() => setOpenMap(!isOpenMap)}
        >
          {isOpenMap ? "Hide" : "Show"} Maps
        </Text>
      )}
      <SimpleGrid columns={1} gap={4}>
        {findAlreadyApprove() && (
          <Box
            display={"flex"}
            experimental_spaceX={2}
            _hover={{ textDecor: "underline", cursor: "pointer" }}
            onClick={() => {
              const address = getValues("address");
              setValue("address", [
                ...address,
                {
                  lngLat: [],
                  name: "",
                },
              ]);
            }}
          >
            <Icons.AddIcons color="black" />
            <Text>Tambah Alamat Pengantaran</Text>
          </Box>
        )}

        {address?.map((i, k) => {
          return (
            <React.Fragment key={k}>
              <InputGroup size="md">
                <Input
                  pr="4.5rem"
                  value={i.name}
                  defaultValue={i.name}
                  placeholder={"Ketik Alamat Pengantaran"}
                  onChange={(e) => {
                    const address = getValues("address");
                    const newArr = address.map((obj, idx) => {
                      if (idx === k) {
                        return {
                          ...obj,
                          name: e.target.value,
                        };
                      }
                      return obj;
                    });
                    setValue("address", newArr);
                  }}
                />
                <InputRightElement width="4.5rem">
                  <IconButton
                    h="1.75rem"
                    aria-label="icon maps"
                    icon={<GoLocation color={"red"} />}
                    onClick={() => {
                      setOpenMap(true);
                      setIdxMaps({
                        idx: k,
                        type: "shipping",
                      });
                    }}
                  />
                </InputRightElement>
              </InputGroup>

              <Divider />
            </React.Fragment>
          );
        })}
      </SimpleGrid>
    </Box>
  );
};

const Pemilik = () => {
  const {
    setValue,
    register,
    getValues,
    formState: { errors },
  } = React.useContext(CustomerDetailCtx);
  const { preview, onSelectFile, selectedFile, setPreview } = usePickImage();
  const isApprove = userStore((v) => v.isApprove);
  const users = userStore((v) => v.users);

  const [imgUrl, setImgUrl] = React.useState({
    idcard: "/image-thumbnail.png",
  });

  React.useEffect(() => {
    Promise.all([useDownloadImage(getValues("customer.idCardPath"))]).then(
      (i) => {
        setImgUrl({ idcard: i[0] });
        setPreview(i[0]);
      }
    );
  }, [getValues("customer.idCardPath")]);

  React.useEffect(() => {
    if (selectedFile) {
      setValue("customer.image_", selectedFile);
    }
  }, [selectedFile]);

  return (
    <React.Fragment>
      <SimpleGrid columns={2} gap={10}>
        <Box experimental_spaceY={3}>
          {isApprove ? (
            <Box w={"fit-content"} h={"fit-content"}>
              <Images
                label="Foto KTP"
                w={300}
                h={200}
                src={imgUrl.idcard as string}
                objectFit="cover"
              />
            </Box>
          ) : (
            <Box w={"fit-content"} h={"fit-content"}>
              <ImagePick
                title="Foto KTP"
                w={300}
                h={200}
                idImage="ktp"
                imageUrl={preview as string}
                onChangeInput={(e) => onSelectFile(e.target)}
              />
            </Box>
          )}

          <FormControls
            type={"number"}
            readOnly={isApprove}
            label="customer.idCardNumber"
            register={register}
            title={"NIK"}
            errors={errors.customer?.idCardNumber?.message}
            required={"Nik tidak boleh kosong"}
          />
          {isApprove ? (
            <VStack align={"start"}>
              <Text fontWeight={500} fontSize={"sm"}>
                Nomor HP
              </Text>
              <Input readOnly value={`${users?.phone}`} />
            </VStack>
          ) : (
            <FormControls
              readOnly={isApprove}
              label="customer.phone"
              register={register}
              title={"Nomor HP"}
              errors={errors.customer?.phone?.message}
              required={"Nomor HP tidak boleh kosong"}
            />
          )}
        </Box>
        {isApprove ? (
          <VStack align={"start"}>
            <Text fontWeight={500} fontSize={"sm"}>
              Email
            </Text>
            <Input readOnly value={`${users?.email}`} />
          </VStack>
        ) : (
          <Box experimental_spaceY={3}>
            <FormControls
              readOnly={isApprove}
              label="customer.email"
              register={register}
              title={"Email"}
              errors={errors.customer?.address?.message}
            />
          </Box>
        )}
      </SimpleGrid>
    </React.Fragment>
  );
};

const Pic = () => {
  const {
    setValue,
    register,
    getValues,
    formState: { errors },
  } = React.useContext(CustomerDetailCtx);
  const isApprove = userStore((v) => v.isApprove);
  const [isChecked, setIsChecked] = React.useState(false);
  const { preview, onSelectFile, selectedFile, setPreview } = usePickImage();
  const isOpenCreate = userStore((v) => v.isOpenCreate);
  const [imgUrl, setImgUrl] = React.useState({
    idcard: "/image-thumbnail.png",
  });

  React.useEffect(() => {
    Promise.all([useDownloadImage(getValues("pic.idCardPath"))]).then((i) => {
      setImgUrl({ idcard: i[0] });
      setPreview(i[0]);
    });
  }, [getValues("pic.idCardPath")]);

  React.useEffect(() => {
    if (selectedFile) {
      setValue("pic.image_", selectedFile);
    }
  }, [selectedFile, preview]);

  const onCheck = (e: boolean) => {
    setIsChecked(!isChecked);
    if (e) {
      const img = getValues("customer.image_");
      if (img) {
        const reader = new FileReader();
        reader.addEventListener("load", () => {
          setPreview(reader.result);
        });
        reader.readAsDataURL(img);
      }

      const customer = getValues("customer");
      setValue("pic.name", customer.name);
      setValue("pic.idCardNumber", customer.idCardNumber);
      setValue("pic.phone", customer.phone);
      setValue("pic.email", customer.email);
      setValue("pic.address", customer.address);
      setValue("pic.idCardPath", customer.idCardPath);
      setValue("pic.image_", img);
    }
  };

  return (
    <React.Fragment>
      {isOpenCreate && (
        <>
          {!isApprove && (
            <Checkbox onChange={(e) => onCheck(e.target.checked)}>
              Samakan Data Pemilik
            </Checkbox>
          )}
        </>
      )}
      <SimpleGrid columns={2} gap={10}>
        <Box experimental_spaceY={3}>
          {/* {isApprove ? ( */}
          {/* // <Box w={'fit-content'} h={'fit-content'}> */}
          {/* <Image title="Foto Usaha" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" /> */}
          {/* </Box> */}
          {/* // ) : ( */}
          <Box w={"fit-content"} h={"fit-content"}>
            <ImagePick
              title="Foto KTP"
              w={300}
              h={200}
              idImage="ktp2"
              imageUrl={preview as string}
              onChangeInput={(e) => onSelectFile(e.target)}
            />
          </Box>
          {/* // )} */}

          <FormControls
            type={"number"}
            label="pic.idCardNumber"
            register={register}
            title={"NIK"}
            errors={errors.pic?.idCardNumber?.message}
            required={"Nama tidak boleh kosong"}
          />
          <FormControls
            label="pic.name"
            register={register}
            title={"Nama"}
            errors={errors.pic?.name?.message}
            required={"Nama tidak boleh kosong"}
          />
        </Box>
        <Box experimental_spaceY={3}>
          <FormControls
            label="pic.phone"
            register={register}
            title={"Nomor HP"}
            errors={errors.pic?.phone?.message}
            required={"Nomor HP tidak boleh kosong"}
          />
          <FormControls
            label="pic.address"
            register={register}
            title={"Alamat"}
            errors={errors.pic?.address?.message}
            required={"Alamat tidak boleh kosong"}
          />
          <FormControls
            label="pic.email"
            register={register}
            title={"Email"}
            errors={errors.pic?.phone?.message}
            required={"Email tidak boleh kosong"}
          />
        </Box>
      </SimpleGrid>
    </React.Fragment>
  );
};

const Legalitas = () => {
  const { setValue, getValues, control } = React.useContext(CustomerDetailCtx);
  const isApprove = userStore((v) => v.isApprove);
  const { preview, onSelectFile, selectedFile, setPreview } = usePickImage();
  const [imgUrl, setImgUrl] = React.useState({
    idcard: "/image-thumbnail.png",
  });
  const setDefault = () => {
    const findDay = DayTax.find(
      (v) => v.value === `${getValues("tax.exchangeDay")}`
    );
    const findType = StatusTax.find(
      (v) => v.value === `${getValues("tax.type")}`
    );
    if (findDay) {
      setValue("_day", findDay);
    }
    if (findType) {
      setValue("_type", findType);
    }
  };

  React.useEffect(() => {
    Promise.all([useDownloadImage(getValues("tax.legalityPath"))]).then((i) => {
      setImgUrl({ idcard: i[0] });
      setPreview(i[0]);
    });
    if (isApprove) {
      setDefault();
    }
  }, [getValues("tax.legalityPath")]);

  React.useEffect(() => {
    if (selectedFile) {
      setValue("tax.image_", selectedFile);
    }
  }, [selectedFile]);

  return (
    <React.Fragment>
      <SimpleGrid columns={2} gap={10}>
        <Box experimental_spaceY={3}>
          {/* {isApprove ? (
                        <Box w={'fit-content'} h={'fit-content'}>
                            <Image title="Foto Usaha" w={300} h={200} src={imgUrl.idcard as string} objectFit="cover" />
                        </Box>
                    ) : (
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto NPWP"
                                w={300}
                                h={200}
                                idImage="npwp"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                    )} */}
          <Box w={"fit-content"} h={"fit-content"}>
            <ImagePick
              title="Foto NPWP"
              w={300}
              h={200}
              idImage="npwp"
              imageUrl={preview as string}
              onChangeInput={(e) => onSelectFile(e.target)}
            />
          </Box>

          <FormSelects
            label={"_day"}
            defaultValue={getValues("_day")}
            control={control}
            title={"Hari Tukar Faktur (*Jika Berlaku)"}
            placeholder={"Pilih Hari Tukar Faktur (*Jika Berlaku)"}
            options={DayTax}
          />
        </Box>
        <Box>
          <FormSelects
            label={"_type"}
            control={control}
            defaultValue={getValues("_type")}
            title="Status Pajak (*Jika Berlaku)"
            options={StatusTax}
            placeholder={"Pilih Status Pajak"}
          />
        </Box>
      </SimpleGrid>
    </React.Fragment>
  );
};

const LimitTOP = () => {
  const {
    register,
    getValues,
    formState: { errors },
    control,
  } = React.useContext(CustomerDetailCtx);
  const isApprove = userStore((v) => v.isApprove);
  return (
    <React.Fragment>
      <Flex experimental_spaceX={10}>
        <Box>
          <Text fontSize={"sm"}>Transaksi Bulan Lalu</Text>
          <Text fontWeight={"bold"}>
            {Shared.formatRupiah(`$${getValues("transactionLastMonth")}`)}
          </Text>
        </Box>
        <Box>
          <Text fontSize={"sm"}>Transaksi Terakhir</Text>
          <Text fontWeight={"bold"}>
            {Shared.formatRupiah(
              `$${Math.ceil(getValues("transactionPerMonth"))}`
            )}
          </Text>
        </Box>
      </Flex>
      <Divider mb="10px" />
      <SimpleGrid columns={3} gap={5}>
        {isApprove ? (
          <VStack align={"start"}>
            <Text fontWeight={500} fontSize={"sm"}>
              Limit
            </Text>
            <Input
              readOnly
              value={`${Shared.formatRupiah(
                String(getValues("creditProposal.limit"))
              )}`}
            />
          </VStack>
        ) : (
          <FormControlNumber
            control={control}
            label="creditProposal.limit"
            register={register}
            title={"Limit"}
            placeholder={"Ketik Limit"}
            errors={errors.creditProposal?.limit?.message}
          />
        )}

        <FormControls
          readOnly={isApprove}
          control={control}
          label="creditProposal.term"
          register={register}
          title={"Term (hari)"}
          placeholder={"Ketik Term"}
          errors={errors.creditProposal?.term?.message}
        />
        <FormControls
          readOnly={isApprove}
          control={control}
          label="creditProposal.termInvoice"
          register={register}
          title={"Invoice Term (hari)"}
          placeholder={"Ketik Term Invoice"}
          errors={errors.creditProposal?.termInvoice?.message}
        />
      </SimpleGrid>
    </React.Fragment>
  );
};

const listNavigation = [
  "Profil Usaha",
  "Alamat Pengantaran",
  "Pemilik",
  "PIC",
  "Legalitas",
  "TOP",
];

export const BusinessDetailApplyPages: React.FC<{ id: string }> = ({ id }) => {
  const isOpenEdit = disclousureStore((v) => v.isOpenEdit);
  const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit);

  return (
    <Wrapper>
      <CustomerDetailApply
        id={id}
        isOpens={isOpenEdit}
        setOpen={setIsOpenEdit}
      />
    </Wrapper>
  );
};

const CustomerDetailApply: React.FC<{
  isOpens: boolean;
  setOpen: (v: boolean) => void;
  id: string;
}> = ({ isOpens, setOpen, id }) => {
  const admin = store.useStore((i) => i.admin);
  const {
    isOpen: isOpenDrawer,
    onOpen,
    onClose: onCloseDrawer,
  } = useDisclosure();
  const { approveApply } = customersService.useCustomer();

  const { data, error, isLoading } =
    customersService.useGetCustomerApplyById(id);
  const { reset, getValues } = React.useContext(CustomerDetailCtx);

  React.useEffect(() => {
    if (data) {
      reset({
        ...data,
      });
    }
  }, [isLoading]);

  const onClose = () => setOpen(false);

  const findAlreadyApprove = () => {
    if (!admin) return;

    const find = data?.userApprover?.find((v) => v.id === admin.id);
    if (find) return true;
    return false;
  };

  // console.log(data)

  return (
    <Modals
      isOpen={isOpens}
      setOpen={onClose}
      size={"6xl"}
      title="Detail Bisnis"
      scrlBehavior="outside"
    >
      {error && <PText label={error} />}
      {isLoading && <Spinner />}
      {!isLoading && !error && data && (
        <>
          {/*  */}
          <Drawer
            isOpen={isOpenDrawer}
            placement="right"
            onClose={onCloseDrawer}
            size={"sm"}
          >
            <DrawerContent>
              <VStack align={"start"} p={5}>
                {error ? (
                  <PText label={error} />
                ) : (
                  <>
                    {data?.userApprover?.map((i, idx, arrLength) => (
                      <TimeLineApproval
                        key={idx}
                        note={i.note}
                        dataLenght={arrLength.length}
                        idx={idx}
                        imageUrl={i.imageUrl}
                        name={i.name}
                        roles={`${i.roles}`}
                        status={i.status}
                        updatedAt={i.updatedAt}
                      />
                    ))}
                  </>
                )}
              </VStack>
            </DrawerContent>
          </Drawer>
          {/*  */}
          <Box h={"650px"}>
            <TabsComponent
              TabList={listNavigation}
              defaultIndex={0}
              link={""}
              isLazy={false}
            >
              <TabPanel px={0}>
                <ProfileUsaha />
              </TabPanel>

              <TabPanel px={0}>
                <ShippingAddressCard />
              </TabPanel>
              <TabPanel px={0} pt={8}>
                <Pemilik />
              </TabPanel>
              <TabPanel px={0} pt={8}>
                <Pic />
              </TabPanel>

              <TabPanel px={0} pt={8}>
                <Legalitas />
              </TabPanel>

              <TabPanel px={0} pt={8}>
                <LimitTOP />
              </TabPanel>
            </TabsComponent>
            <>
              <Text
                w="fit-content"
                onClick={onOpen}
                textDecor={"underline"}
                cursor="pointer"
              >
                Lihat Approver
              </Text>
              {findAlreadyApprove() && (
                <Box bottom={3} right={5} w="96%" pos="absolute">
                  <ButtonForm
                    type="button"
                    onClick={() =>
                      onCreate({
                        approveApply,
                        onClose,
                        rData: getValues(),
                        adminId: `${admin?.id}`,
                      })
                    }
                    isLoading={approveApply.isLoading}
                    label="Terima"
                    labelClose="Tolak"
                    onClose={onClose}
                  />
                </Box>
              )}
            </>
          </Box>
        </>
      )}
    </Modals>
  );
};

/**
 * CREATE CUSTOMER APPLY
 * @param param0
 * @returns
 */

export const CustomerCreateApplyPages: React.FC<{
  isOpens: boolean;
  setOpen: (v: boolean) => void;
}> = ({ isOpens, setOpen }) => {
  const onClose = () => {
    setOpen(false);
  };

  return (
    <Modals
      isOpen={isOpens}
      setOpen={onClose}
      size={"6xl"}
      title="Tambah Bisnis"
      scrlBehavior="outside"
    >
      <Wrapper>
        <CustomerApplys />
      </Wrapper>
    </Modals>
  );
};

/**
 * DETAIL CUSTOMER APPLY
 * @returns
 */
export const WrapCustomerApplys = () => {
  return (
    <Wrapper>
      <CustomerApplys />
    </Wrapper>
  );
};

const CustomerApplys: React.FC = () => {
  const user = userStore((v) => v.user);
  const users = userStore((v) => v.users);
  const isApprove = userStore((v) => v.isApprove);
  const setOpenDetailBusiness = userStore((v) => v.setOpenDetailBusiness);
  const admin = store.useStore((v) => v.admin);
  const [currentIdx, setCurrentIdx] = React.useState(0);
  const toast = useToast();
  const { createCustomerApply, createCustomer, updateBusiness } =
    customersService.useCustomer();
  const { reset, getValues } = React.useContext(CustomerDetailCtx);

  React.useEffect(() => {
    if (user) {
      reset({
        ...user,
      });
    }
  }, [user]);

  const setHeight = React.useMemo(() => {
    if (window.screen.availWidth >= 1920) {
      return "600px";
    }
    if (window.screen.availWidth >= 1535) {
      return "550px";
    }
    if (window.screen.availWidth >= 1440) {
      return "558px";
    }
    if (window.screen.availWidth >= 1366) {
      return "558px";
    }

    return "100%";
  }, [window.screen.availWidth]);

  const setMt = React.useMemo(() => {
    if (window.screen.availWidth >= 1920) {
      return "-100px";
    }
    if (window.screen.availWidth >= 1535) {
      return "-110px";
    }
    if (window.screen.availWidth >= 1440) {
      return "-110px";
    }
    if (window.screen.availWidth >= 1366) {
      return "-110px";
    }

    return "100%";
  }, [window.screen.availWidth]);

  const findAlreadyApprove = () => {
    if (!admin) return;

    const find = getValues().userApprover?.find((v) => v.id === admin.id);
    if (find) return true;
    return false;
  };

  return (
    <>
      <Box h={setHeight}>
        <TabsComponent
          TabList={listNavigation}
          defaultIndex={0}
          link={""}
          isLazy={false}
          onChange={(e) => setCurrentIdx(e)}
        >
          <TabPanel px={0}>
            <ProfileUsaha />
          </TabPanel>

          <TabPanel px={0}>
            <ShippingAddressCard />
          </TabPanel>
          <TabPanel px={0} pt={8}>
            <Pemilik />
          </TabPanel>
          <TabPanel px={0} pt={8}>
            <Pic />
          </TabPanel>

          <TabPanel px={0} pt={8}>
            <Legalitas />
          </TabPanel>

          <TabPanel px={0} pt={8}>
            <LimitTOP />
          </TabPanel>
        </TabsComponent>

        {/*  */}
      </Box>

      <>
        {findAlreadyApprove() && (
          <>
            <p style={{ display: "none" }}>{currentIdx}</p>
            {isApprove && currentIdx !== 5 && currentIdx !== 2 && (
              <Box position={"fixed"} w={"68rem"} mt={setMt}>
                <ButtonForm
                  onClick={() => {
                    if (isApprove) {
                      if (!users) return;
                      onUpdateBussiness({
                        onClose: () => setOpenDetailBusiness(false),
                        rData: getValues(),
                        toast,
                        roles: users.business.viewer,
                        updateBusiness,
                      });
                    }
                  }}
                  type="button"
                  isLoading={createCustomerApply.isLoading}
                  label="Simpan"
                  onClose={() => setOpenDetailBusiness(false)}
                />
              </Box>
            )}
            {currentIdx === 5 && !isApprove && (
              <Box position={"fixed"} w={"68rem"} mt={setMt}>
                <ButtonForm
                  onClick={() => {
                    if (!isApprove) {
                      if (!user) return;
                      onCreateApply({
                        createCustomerApply,
                        onClose: () => setOpenDetailBusiness(false),
                        rData: getValues(),
                        roles: user.viewer,
                        createCustomer,
                        toast,
                      });
                    }
                  }}
                  type="button"
                  isLoading={createCustomerApply.isLoading}
                  label="Simpan"
                  onClose={() => setOpenDetailBusiness(false)}
                />
              </Box>
            )}
          </>
        )}
      </>
    </>
  );
};

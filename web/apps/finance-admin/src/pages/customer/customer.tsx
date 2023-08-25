import React, { useEffect, useState, FC, ReactNode } from "react";
import {
  Tables,
  SearchInput,
  Root,
  Types,
  PagingButton,
  PText,
  Columns,
  ButtonTooltip,
  Icons,
} from "ui";
import { create } from "zustand";
import { dataListCustomer } from "~/navigation";
import { HStack } from "@chakra-ui/layout";
import { customersService, store } from "hooks";
import { CustomerApply, Customers, Eroles } from "apis";
import DetailCustomer from "./customer-details";
import { disclousureStore } from "~/store";

interface IStore {
  user?: CustomerApply | undefined;
  setUser: (v: CustomerApply | undefined) => void;
  users?: Customers;
  setUsers: (v?: Customers | undefined) => void;
  isApprove: boolean;
  setIsApprove: (v: boolean) => void;
  isOpenDetailBusiness: boolean;
  setOpenDetailBusiness: (v: boolean) => void;
  isOpenUpdateLimit: boolean;
  setOpenUpdateLimit: (v: boolean) => void;
  isOpenCreate: boolean;
  setOpenCreate: (v: boolean) => void;
}

export const userStore = create<IStore>((set) => ({
  user: undefined,
  users: undefined,
  isOpenDetailBusiness: false,
  isOpenUpdateLimit: false,
  isOpenCreate: false,
  setOpenCreate: (v) => set({ isOpenCreate: v }),
  setOpenUpdateLimit: (v) => set({ isOpenUpdateLimit: v }),
  setOpenDetailBusiness: (v) => set({ isOpenDetailBusiness: v }),
  setUsers: (v) => {
    set({
      users: v,
    });
  },
  setUser: (v) => set({ user: v }),
  setIsApprove: (v) => set({ isApprove: v }),
  isApprove: false,
}));

const Wrap: FC<{ children: ReactNode }> = ({ children }) => (
  <Root appName="Finance" items={dataListCustomer} backUrl={"/"} activeNum={1}>
    {children}
  </Root>
);

const CustomerPages = () => {
  const { column, id } = columnsUser();
  const isOpenDetailBusiness = userStore((v) => v.isOpenDetailBusiness);
  // const users = userStore((v) => v.users);
  const admin = store.useStore((v) => v.admin);
  const setOpenAdd = disclousureStore((v) => v.setOpenAdd);
  const { data, page, error, isLoading, onSetQuerys } =
    customersService.useGetCustomers();

  React.useEffect(() => {
    if (admin && admin.roles === Eroles.BRANCH_FINANCE_ADMIN) {
      onSetQuerys({
        branchId: admin.location.id,
      });
    }
  }, [admin]);

  return (
    <Wrap>
      {isOpenDetailBusiness && id && <DetailCustomer customerId={id.id} />}
      <SearchInput
        placeholder="Cari Pelanggan"
        onChange={(e) => onSetQuerys({ search: e.target.value })}
        onClick={() => setOpenAdd(true)}
      />
      {error ? (
        <PText label={error} />
      ) : (
        <>
          <Tables
            columns={column}
            data={isLoading ? [] : data.items}
            isLoading={isLoading}
          />
          <PagingButton
            page={Number(page)}
            nextPage={() => onSetQuerys({ page: Number(page) + 1 })}
            prevPage={() => onSetQuerys({ page: Number(page) - 1 })}
            disableNext={data?.next === null}
          />
        </>
      )}
    </Wrap>
  );
};

export default CustomerPages;

// type UserTypes = DataTypes.CustomerTypes.Customers

const columnsUser = () => {
  const setIsApprove = userStore((v) => v.setIsApprove);
  const setUsers = userStore((v) => v.setUsers);
  const setOpenDetailBusiness = userStore((v) => v.setOpenDetailBusiness);
  const setOpenUpdateLimit = userStore((v) => v.setOpenUpdateLimit);

  const [id, setId] = React.useState<Customers>();
  const [isOpenDetail, setOpenDetail] = React.useState(false);
  const [isOpenCreate, setOpenCreate] = React.useState(false);
  const cols = Columns.columnsUser;

  const column: Types.Columns<Customers>[] = [
    cols.name,
    cols.phone,
    cols.email,
    {
      header: "Status",
      render: (v) => <>{v.business ? "Bisnis" : "Walk-In"}</>,
    },
    {
      header: "Tindakan",
      render: (v) => (
        <HStack>
          <ButtonTooltip
            label={"Detail"}
            icon={<Icons.IconDetails color={"gray"} />}
            onClick={() => {
              setOpenDetailBusiness(true);
              setId(v);
              setUsers(v);
            }}
          />
        </HStack>
      ),
    },
  ];

  return {
    column,
    isOpenDetail,
    setOpenDetail,
    id,
    isOpenCreate,
    setOpenCreate,
  };
};

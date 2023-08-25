import React from "react";
import { customersService, store } from "hooks";
import { CustomerApply, TypeCustomerApply } from "apis";
import {
  ButtonTooltip,
  entity,
  Icons,
  PagingButton,
  PText,
  Root,
  StackAvatar,
  Tables,
  Types,
} from "ui";
import { Text } from "@chakra-ui/layout";
import { dataListCustomer } from "~/navigation";

import { disclousureStore } from "~/store";
import { BusinessDetailApplyPages } from "../customer/customer-detail-apply";

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <Root appName="Sales" items={dataListCustomer} backUrl={"/"} activeNum={2}>
    {children}
  </Root>
);

const CustomerApplyPages = () => {
  const admin = store.useStore((v) => v.admin);
  const isOpenEdit = disclousureStore((v) => v.isOpenEdit);

  const { data, error, isLoading, setPage, page } =
    customersService.useGetCustomerApply({
      type: TypeCustomerApply.WAITING_APPROVE,
      userId: `${admin?.id}`,
    });

  const { column, data: dataDetail } = columns();

  // console.log(data.items)
  return (
    <Wrap>
      {isOpenEdit && dataDetail && <BusinessDetailApplyPages id={dataDetail.id} />}
      {error ? (
        <PText label={error} />
      ) : (
        <Tables
          columns={column}
          data={isLoading ? [] : data.items}
          isLoading={isLoading}
        />
      )}
      <PagingButton
        page={page}
        nextPage={() => setPage(page + 1)}
        prevPage={() => setPage(page - 1)}
        disableNext={data?.next === null}
      />
    </Wrap>
  );
};

function columns() {
  const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit);
  const [data, setData] = React.useState<CustomerApply>();

  const column: Types.Columns<CustomerApply>[] = [
    {
      header: "Nama Pemilik",
      render: (v) => (
        <StackAvatar name={v.customer.name} imageUrl={v.customer.imageUrl} />
      ),
    },

    {
      header: "Nama PIC",
      render: (v) => <Text>{v.pic.name}</Text>,
    },
    {
      header: "Status",
      render: (v) => <Text>{entity.statusApply(v.status)}</Text>,
    },
    {
      header: "Jenis Pengajuan",
      render: (v) => <Text>{v.type === 1 ? "Bisnis" : "Limit"}</Text>,
    },
    {
      header: "Cabang",
      render: (v) => <Text>{v.location.branchName}</Text>,
    },
    {
      header: "Tindakan",
      render: (v) => (
        <ButtonTooltip
          label={"Detail"}
          icon={<Icons.IconDetails color={"gray"} />}
          onClick={() => {
            setIsOpenEdit(true);
            setData(v);
          }}
        />
      ),
    },
  ];

  return { column, data, setData };
}

export default CustomerApplyPages;

import React from "react";
import {
  Root,
  SearchInput,
  Tables,
  PText,
  Columns,
  Types,
  ButtonTooltip,
  Icons,
  PagingButton,
} from "ui";
import { HStack, Tooltip } from "@chakra-ui/react";
import FilterProduct from "./product-filter";
import { dataListProduct } from "~/navigation";
import { productService, store } from "hooks";
import { Eroles, ProductTypes } from "apis";
import { useSearchParams } from "react-router-dom";

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <Root appName="Finance" items={dataListProduct} backUrl={"/"} activeNum={1}>
      {children}
    </Root>
  );
};
const useParams = () => {
  const [searchParams] = useSearchParams();
  if (searchParams.get("team") === "null") {
    return "";
  }
  return searchParams.get("team");
};

const ProductPages = () => {
  const admin = store.useStore((v) => v.admin);
  const [query] = useSearchParams();
  const [openFilter, setOpenFilter] = React.useState(false);
  const { column, id, isOpen, setOpen } = columns();
  const searchParam = useParams();

  const qeryData = {
    branchId: `${
      admin?.roles !== undefined &&
      `${admin.roles}` === `${Eroles.FINANCE_ADMIN}`
        ? query.get("branchId") || ""
        : admin?.location.id
    }`,
    brandId: query.get("brandId") || "",
    categoryId: query.get("categoryId") || "",
    team: query.get("team") || "",
    salesId: query.get("salesId") || "",
  };

  const { data, setQ, error, isLoading, page, setPage } =
    productService.useGetProduct({
      ...qeryData,
    });

  const binding = () => {
    if (isLoading) {
      return [];
    }

    return data;
  };

  return (
    <Wrap>
      <HStack w="fit-content">
        <SearchInput
          placeholder="Cari Produk"
          onChange={(e) => setQ(e.target.value)}
        />
        <Tooltip label="Filter">
          <FilterProduct
            isRoles={`${admin?.roles}`}
            isOpen={openFilter}
            onOpen={setOpenFilter}
          />
        </Tooltip>
      </HStack>

      {error ? (
        <PText label={error} />
      ) : (
        <>
          <Tables
            columns={column}
            isLoading={isLoading}
            data={binding()}
            usePaging={true}
          />
          <PagingButton
            page={page}
            nextPage={() => setPage(page + 1)}
            prevPage={() => setPage(page - 1)}
            disableNext={false}
          />
        </>
      )}
    </Wrap>
  );
};

export default ProductPages;

const columns = () => {
  const cols = Columns.columnsProduct;
  const [id, setId] = React.useState<ProductTypes.Product | undefined>();
  const [isOpen, setOpen] = React.useState(false);
  const [isAddStock, setAddStock] = React.useState(false);

  const column: Types.Columns<ProductTypes.Product>[] = [
    cols.id,
    cols.name,
    cols.point,
    cols.size,
    cols.brand,
    cols.category,
    cols.createdAt,
    // {
    //   header: "Tindakan",
    //   render: (v) => (
    //     <ButtonTooltip
    //       label={"Detail"}
    //       icon={<Icons.IconDetails color={"gray"} />}
    //       onClick={() => {
    //         setOpen(true);
    //         setId(v);
    //       }}
    //     />
    //   ),
    // },
  ];

  return { column, id, isOpen, setOpen, isAddStock, setAddStock };
};

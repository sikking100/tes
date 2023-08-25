import React from 'react'
import { InputSearch, PagingButton, PText, Root, Tables } from 'ui'
import { dataListProduct } from '~/navigation'
import columns from './product-qty-column'
import { Drawer, DrawerContent, HStack, DrawerCloseButton, DrawerHeader, DrawerBody, Text } from '@chakra-ui/react'
import MoveQty from './move-qty'
import { store, productService, setHeight } from 'hooks'
import { disclousureStore } from '~/store'
import { ProductTypes } from 'apis'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={dataListProduct} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const DetailWarehouse: React.FC<{ id: string }> = ({ id }) => {
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const onClose = () => setIsOpenEdit(false)
    const { data, error, isLoading } = productService.useGetProductBranchById(id)

    return (
        <Drawer isOpen={isOpenEdit} placement="right" onClose={onClose}>
            <DrawerContent>
                <DrawerCloseButton />
                <DrawerHeader>List Gudang</DrawerHeader>

                <DrawerBody>
                    {error ? (
                        <PText label={error} />
                    ) : (
                        <Tables<ProductTypes.Warehouse>
                            data={!data ? [] : data.warehouse}
                            isLoading={isLoading}
                            columns={[
                                {
                                    header: 'Nama',
                                    render: (v) => <Text>{v.name}</Text>,
                                },
                                {
                                    header: 'Stok',
                                    render: (v) => <Text>{v.qty}</Text>,
                                },
                            ]}
                        />
                    )}
                </DrawerBody>
            </DrawerContent>
        </Drawer>
    )
}

const ProductQtyPages = () => {
    const admin = store.useStore((i) => i.admin)
    const height = setHeight({ useSearch: true })
    const { data, error, isLoading, onSetQuerys, querys, onSetPage } = productService.useGetProductBranch()
    const { column, id, isOpen, setOpen } = columns()
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    React.useEffect(() => {
        if (admin) {
            onSetQuerys({ branchId: admin.location.id })
        }
    }, [admin])

    return (
        <Wrap>
            {isOpenEdit && id && <DetailWarehouse id={id.id} />}
            {isOpen && id && <MoveQty isOpen={isOpen} setOpen={setOpen} productId={id.id} />}

            <HStack w="fit-content" mb={'10px'}>
                <InputSearch
                    placeholder={'Cari Produk'}
                    text=""
                    onChange={(e) => {
                        onSetQuerys({ search: e.target.value })
                    }}
                />
            </HStack>

            <>
                {error ? (
                    <PText label={error} />
                ) : (
                    <>
                        <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data.items || []} pageH={height} />
                        <PagingButton
                            page={Number(querys.page)}
                            nextPage={() => onSetPage(Number(querys.page) + 1)}
                            prevPage={() => onSetPage(Number(querys.page) - 1)}
                            disableNext={data?.next === null}
                        />
                    </>
                )}
            </>
        </Wrap>
    )
}

export default ProductQtyPages

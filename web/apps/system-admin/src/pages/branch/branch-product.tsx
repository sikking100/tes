import React from 'react'
import { Branch, ProductTypes } from 'apis'
import { ButtonTooltip, Columns, entity, Icons, Modals, PagingButton, PText, SearchInput, Tables, Types } from 'ui'
import { productService } from 'hooks'
import { Text } from '@chakra-ui/layout'
import { Drawer, DrawerCloseButton, DrawerContent, DrawerHeader, DrawerBody } from '@chakra-ui/react'

interface Props {
    isOpen: boolean
    setOpen: (v: boolean) => void
    branch: Branch
}

const DetailWarehouse: React.FC<{ isOpen: boolean; setOpen: (v: boolean) => void; id: string }> = ({ id, isOpen, setOpen }) => {
    const onClose = () => setOpen(false)

    const { data, error, isLoading } = productService.useGetProductBranchById(id)

    return (
        <Drawer isOpen={isOpen} placement="right" onClose={onClose}>
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

const ProductBranch: React.FC<Props> = ({ isOpen, setOpen, branch }) => {
    if (!isOpen) return null

    const { data, error, isLoading, onSetPage, onSetQuerys, querys } = productService.useGetProductBranch()
    const { column, id, isOpenWarehouse, setOpenWarehouse } = columns()

    React.useEffect(() => {
        if (branch) {
            onSetQuerys({
                branchId: branch.id,
            })
        }
    }, [branch])

    const onClose = () => setOpen(false)

    return (
        <Modals isOpen={isOpen} setOpen={onClose} size="6xl" title={`${branch.name}`}>
            {isOpenWarehouse && id && <DetailWarehouse id={id} isOpen={isOpenWarehouse} setOpen={setOpenWarehouse} />}
            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <SearchInput placeholder="Cari Produk" onChange={(e) => onSetQuerys({ search: e.target.value })} />
                    <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data.items} pageH="450px" />
                    <PagingButton
                        page={Number(querys.page)}
                        nextPage={() => onSetPage(Number(querys.page) + 1)}
                        prevPage={() => onSetPage(Number(querys.page) - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Modals>
    )
}

const columns = () => {
    const [isOpenWarehouse, setOpenWarehouse] = React.useState(false)
    const [id, setId] = React.useState('')
    const cols = Columns.columnsProduct
    const column: Types.Columns<ProductTypes.Product>[] = [
        cols.id,
        cols.name,
        cols.point,
        cols.point,
        cols.size,
        cols.brand,
        {
            header: 'Tim',
            render: (v) => <Text>{entity.team(String(v.category.team))}</Text>,
        },
        cols.category,
        {
            header: '',
            render: (v) => (
                <ButtonTooltip
                    icon={<Icons.IconDetails />}
                    aria-label="warehouse"
                    label="Lihat Stok"
                    onClick={() => {
                        setOpenWarehouse(true)
                        setId(v.id)
                    }}
                />
            ),
        },
    ]

    return {
        column,
        isOpenWarehouse,
        setOpenWarehouse,
        id,
    }
}

export default ProductBranch

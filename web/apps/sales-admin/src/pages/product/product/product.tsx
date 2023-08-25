import React from 'react'
import { productService, store } from 'hooks'
import { Root, SearchInput, Tables, PText, Columns, Types, ButtonTooltip, Icons, PagingButton, entity } from 'ui'
import { HStack } from '@chakra-ui/react'
import { listNavigation } from '~/utils'
import { Eroles, ProductTypes } from 'apis'
import ProductDetailPages from './product-detail'
import { disclousureStore } from '~/store'
import FilterProduct from './product-filter'
import { useSearchParams } from 'react-router-dom'
import AddSales from './add-sales'
import { create } from 'zustand'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const admin = store.useStore((i) => i.admin)
    const list = listNavigation(Number(admin?.roles))

    return (
        <Root appName="Sales" items={list} backUrl={'/'} activeNum={1}>
            {children}
        </Root>
    )
}

interface IStorePrduct {
    isProductBranch: boolean
    setProductBranch: (v: boolean) => void
}

export const storeProduct = create<IStorePrduct>((set) => ({
    isProductBranch: false,
    setProductBranch: (v) => set({ isProductBranch: v }),
}))

const ProductPages = () => {
    const [query] = useSearchParams()
    const admin = store.useStore((v) => v.admin)
    const [openFilter, setOpenFilter] = React.useState(false)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setProductBranch = storeProduct((v) => v.setProductBranch)
    const isProductBranch = storeProduct((v) => v.isProductBranch)
    const { column, id, isOpenAddSales, setOpenAddSales } = columns()
    const { data, setQ, error, isLoading, page, setPage } = productService.useGetProduct({
        branchId: admin?.roles === Eroles.BRANCH_SALES_ADMIN ? admin?.location.id : query.get('branchId') || '',
        brandId: query.get('brandId') || '',
        categoryId: query.get('categoryId') || '',
        team: query.get('team') || '',
        salesId: query.get('salesId') || '',
    })

    React.useEffect(() => {
        if (query.get('branchId') && data?.length > 1 && !error) {
            setProductBranch(true)
        }
        if (!query.get('branchId')) {
            setProductBranch(false)
        }
    }, [query.get('branchId'), isLoading])

    return (
        <Wrap>
            <HStack w="fit-content">
                <SearchInput placeholder="Cari Produk" onChange={(e) => setQ(e.target.value)} />
                <FilterProduct isOpen={openFilter} onOpen={setOpenFilter} />
            </HStack>

            {isOpenAddSales && id && isProductBranch && <AddSales isOpen={isOpenAddSales} setOpen={setOpenAddSales} product={id} />}
            {isOpenEdit && id && <ProductDetailPages data={id} />}
            {error ? <PText label={error} /> : <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data} />}

            <PagingButton
                page={page}
                nextPage={() => setPage(page + 1)}
                prevPage={() => setPage(page - 1)}
                disableNext={data?.length < 20}
            />
        </Wrap>
    )
}

export default ProductPages

const columns = () => {
    const cols = Columns.columnsProduct
    const [id, setId] = React.useState<ProductTypes.Product | undefined>()
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const [isOpenAddSales, setOpenAddSales] = React.useState(false)
    const isProductBranch = storeProduct((v) => v.isProductBranch)

    const column: Types.Columns<ProductTypes.Product>[] = [
        cols.id,
        cols.name,
        cols.size,
        cols.category,
        cols.point,
        cols.brand,
        {
            header: 'Tim',
            render: (v) => entity.team(String(v.category.team)),
        },
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                    />
                    {isProductBranch && (
                        <ButtonTooltip
                            label={'Tambah Sales'}
                            icon={<Icons.AccountIcons color={'gray'} />}
                            onClick={() => {
                                setOpenAddSales(true)
                                setId(v)
                            }}
                        />
                    )}
                </HStack>
            ),
        },
    ]

    return { column, id, isOpenAddSales, setOpenAddSales }
}

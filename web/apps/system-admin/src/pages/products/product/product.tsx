import React, { FC, ReactNode } from 'react'
import { productService } from 'hooks'
import type { ProductTypes } from 'apis'
import { ButtonTooltip, Columns, DeleteConfirm, Icons, PText, PagingButton, Root, SearchInput, Tables, Types, entity } from 'ui'
import { dataListProduct } from '~/navigation'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { HStack, Text } from '@chakra-ui/layout'
import FilterProduct from './product-filter'
import { disclousureStore } from '~/store'
import ProductDetailPage from './product-detail'
import ProductAddPages from './product-add'

const Wrap: FC<{ children: ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const useParams = () => {
    const [searchParams] = useSearchParams()
    if (searchParams.get('team') === 'null') {
        return ''
    }
    return searchParams.get('team')
}

const ProductPages = () => {
    const navigate = useNavigate()
    const searchParam = useParams()
    const [openFilter, setOpenFilter] = React.useState(false)
    const { column, id } = columns()
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    const { data, error, isLoading, page, setPage, setQ } = productService.useGetProduct({
        team: searchParam ?? '',
    })
    const { remove } = productService.useProdcut()

    const handleDelete = async () => {
        await remove.mutateAsync(`${id?.id}`)
        setIsOpenDeelete(false)
    }

    const binding = () => {
        if (isLoading) {
            return []
        }

        return data
    }

    return (
        <Wrap>
            {isOpenEdit && id && <ProductDetailPage id={id.id} />}
            {isAdd && <ProductAddPages />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Produk'}
                onClick={handleDelete}
            />
            <HStack w="fit-content">
                <SearchInput
                    labelBtn="Tambah Produk"
                    link={'/product/add'}
                    onClick={() => setOpenAdd(true)}
                    placeholder="Cari Produk"
                    onChange={(e) => setQ(e.target.value)}
                    onClickBtnExp={(e) => {
                        navigate('/product-import', { replace: true })
                        localStorage.setItem('product-import', JSON.stringify(e))
                    }}
                />
                <FilterProduct isOpen={openFilter} onOpen={setOpenFilter} />
            </HStack>

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} isLoading={isLoading} data={binding()} usePaging={true} />
                    <PagingButton page={page} nextPage={() => setPage(page + 1)} prevPage={() => setPage(page - 1)} disableNext={false} />
                </>
            )}
        </Wrap>
    )
}

export default ProductPages

const columns = () => {
    const cols = Columns.columnsProduct
    const [id, setId] = React.useState<ProductTypes.Product | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<ProductTypes.Product>[] = [
        cols.id,
        cols.name,
        cols.point,
        cols.size,
        cols.brand,
        cols.category,
        {
            header: 'Tim',
            render: (v) => <Text>{entity.team(String(v.category.team))}</Text>,
            width: '200px',
        },
        cols.createdAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenDeelete(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id }
}

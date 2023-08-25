import React from 'react'
import { ButtonTooltip, Columns, DeleteConfirm, Icons, PagingButton, PText, Root, SearchInput, Tables, Types } from 'ui'
import { branchService } from 'hooks'
import type { Branch } from 'apis'
import { dataListLocation } from '~/navigation'
import { HStack } from '@chakra-ui/layout'
import ModalDetailWarehouse from './detail-warehouse'
import ProductBranch from './branch-product'
import BranchAddPages from './branch-add'
import BranchDetailPages from './branch-detail'
import { useNavigate } from 'react-router-dom'
import { disclousureStore } from '~/store'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

const BranchPages = () => {
    const isAdd = disclousureStore((v) => v.isAdd)
    const navigate = useNavigate()
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setPrompt = disclousureStore((v) => v.setPrompt)

    const { column, id, isOpenWarehouse, setOpenWarehouse, isOpenProduct, setOpenProduct } = columns()
    const { data, page, setPage, setQ, error, isLoading } = branchService.useGetBranch()
    const { remove } = branchService.useBranch()

    React.useEffect(() => {
        localStorage.removeItem('priceList')
        setPrompt(false)
    }, [])

    const onDelete = async () => {
        await remove.mutateAsync(String(id?.id))
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isAdd && <BranchAddPages />}
            {isOpenEdit && <BranchDetailPages id={id?.id ?? ''} />}
            {isOpenDelete && (
                <DeleteConfirm
                    isLoading={remove.isLoading}
                    isOpen={isOpenDelete}
                    setOpen={() => setIsOpenDeelete(false)}
                    onClose={() => setIsOpenDeelete(false)}
                    desc={'Cabang'}
                    onClick={onDelete}
                />
            )}
            <SearchInput
                labelBtn="Tambah Cabang"
                placeholderBtnExport="Import Cabang"
                link={'/'}
                onClick={() => setOpenAdd(true)}
                placeholder="Cari Cabang"
                onChange={(e) => setQ(e.target.value)}
                onClickBtnExp={(i) => {
                    navigate('/branch-import', { replace: true })
                    localStorage.setItem('branch-import', JSON.stringify(i))
                }}
            />
            {isOpenProduct && id && <ProductBranch branch={id} isOpen={isOpenProduct} setOpen={setOpenProduct} />}
            {isOpenWarehouse && id && <ModalDetailWarehouse branch={id} isOpen={isOpenWarehouse} setOpen={setOpenWarehouse} />}

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data.items} usePaging={true} />
                    <PagingButton
                        page={page}
                        nextPage={() => setPage(page + 1)}
                        prevPage={() => setPage(page - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

export default BranchPages
const columns = () => {
    const cols = Columns.columnsBranch
    const navigate = useNavigate()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)
    const [id, setId] = React.useState<Branch | undefined>()
    const [isOpen, setOpen] = React.useState(false)
    const [isOpenRegion, setOpenRegion] = React.useState(false)
    const [isImportQty, setImportQty] = React.useState(false)
    const [isImportPrice, setImportPrice] = React.useState(false)
    const [isOpenWarehouse, setOpenWarehouse] = React.useState(false)
    const [isOpenProduct, setOpenProduct] = React.useState(false)

    const column: Types.Columns<Branch>[] = [
        cols.region,
        cols.id,
        cols.name,
        cols.address,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'List Produk'}
                        icon={<Icons.ProductIcons color={'gray'} />}
                        onClick={() => {
                            setOpenProduct(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        label={'Harga'}
                        icon={<Icons.IconBookUpload color={'gray'} />}
                        onClick={() => {
                            navigate({ pathname: `/branch/price/${v.id}` })
                        }}
                    />
                    <ButtonTooltip
                        label={'Stok'}
                        icon={<Icons.IconBox color={'gray'} />}
                        onClick={() => {
                            navigate({ pathname: `/branch/qty/${v.id}` })
                        }}
                    />

                    <ButtonTooltip
                        label={'Gudang'}
                        icon={<Icons.IconWarehouse color={'gray'} />}
                        onClick={() => {
                            // setImportQty(true)
                            setOpenWarehouse(true)
                            setId(v)
                        }}
                    />

                    {/* <Link to={`/branch/${v.id}`}> */}
                    <ButtonTooltip
                        onClick={() => {
                            setEdit(true)
                            setId(v)
                        }}
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                    />
                    {/* </Link> */}
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

    return {
        column,
        id,
        isOpen,
        setOpen,
        isOpenRegion,
        setOpenRegion,
        setImportQty,
        isImportQty,
        isImportPrice,
        setImportPrice,
        isOpenWarehouse,
        setOpenWarehouse,
        isOpenProduct,
        setOpenProduct,
    }
}

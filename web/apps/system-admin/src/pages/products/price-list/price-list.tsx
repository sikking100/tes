import React from 'react'
import { ButtonTooltip, DeleteConfirm, Icons, PText, Root, SearchInput, Shared, Tables, Types } from 'ui'
import { priceListService } from 'hooks'
import { dataListProduct } from '~/navigation'
import { useNavigate } from 'react-router-dom'
import { HStack, Text } from '@chakra-ui/layout'
import type { PriceList } from 'apis'
import PriceListAddPages from './price-list-add'
import { disclousureStore } from '~/store'
import PriceListDetailPages from './price-list-detail'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={6}>
        {children}
    </Root>
)

const PriceeListPages = () => {
    const navigate = useNavigate()
    const { column, id } = columns()
    const [isOpenCreate, setOpenCreate] = React.useState(false)
    const { data, error, isLoading } = priceListService.useGetPriceList()
    const { remove } = priceListService.usePriceList()
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const onDelete = async () => {
        await remove.mutateAsync(String(id?.id))
        setIsOpenDeelete(false)
    }

    const onSearch = (e: string) => {
        data?.filter((i) => i.name.toLowerCase().includes(e.toLowerCase()))
    }

    return (
        <Wrap>
            {isOpenEdit && id && <PriceListDetailPages id={id.id} />}
            {isOpenDelete && (
                <DeleteConfirm
                    isLoading={remove.isLoading}
                    isOpen={isOpenDelete}
                    setOpen={() => setIsOpenDeelete(false)}
                    onClose={() => setIsOpenDeelete(false)}
                    desc={'Kategori Harga'}
                    onClick={onDelete}
                />
            )}
            {isOpenCreate && <PriceListAddPages isOpen={isOpenCreate} setOpen={setOpenCreate} />}
            <SearchInput
                labelBtn="Tambah Kategori Harga"
                link={'.'}
                onClick={() => setOpenCreate(true)}
                placeholder="Cari Kategori Harga"
                onChange={(e) => onSearch(e.target.value)}
                onClickBtnExp={(i) => {
                    navigate('/price-list-import', { replace: true })
                    localStorage.setItem('price-list-import', JSON.stringify(i))
                }}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data} usePaging={true} />
            )}
        </Wrap>
    )
}

export default PriceeListPages

const columns = () => {
    const [id, setId] = React.useState<PriceList | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<PriceList>[] = [
        {
            header: 'ID',
            render: (v) => <Text>{v.id}</Text>,
        },
        {
            header: 'Nama',
            render: (v) => <Text>{v.name}</Text>,
        },
        {
            header: 'Tanggal Dibuat',
            render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
        },
        {
            header: 'Tanggal Diperbarui',
            render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
        },
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    {/* <Link to={`/price-list/${v.id}`}> */}
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
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

    return { column, id }
}

import React from 'react'
import { brandService } from 'hooks'
import type { Brand } from 'apis'
import { ButtonTooltip, Columns, DeleteConfirm, Icons, PText, Root, SearchInput, Tables, Types } from 'ui'
import { dataListProduct } from '~/navigation'
import { HStack } from '@chakra-ui/layout'
import BrandAddPages from './brand-add'
import BrandDetailPages from './brand-detail'
import { disclousureStore } from '~/store'
import { useNavigate } from 'react-router-dom'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={3}>
        {children}
    </Root>
)

const BrandPages = () => {
    const { column, id } = columns()
    const { data, error, isLoading } = brandService.useGetBrand()
    const { remove } = brandService.useBrand()
    const navigate = useNavigate()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const pBrand = data

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDeelete(false)
    }

    const onSearch = (e: string) => {
        pBrand?.filter((i) => i.name.toLowerCase().includes(e.toLowerCase()))
    }

    return (
        <Wrap>
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Brand'}
                onClick={() => handleDelete(String(id?.id))}
            />

            {isAdd && <BrandAddPages />}

            {isOpenEdit && id && <BrandDetailPages id={id.id} />}

            <SearchInput
                labelBtn="Tambah Brand"
                link={'/brand/add'}
                onClick={() => setOpenAdd(true)}
                placeholder="Cari Brand"
                onChange={(e) => onSearch(e.target.value)}
                onClickBtnExp={(e) => {
                    navigate('/brand-import', { replace: true })
                    localStorage.setItem('brand-import', JSON.stringify(e))
                }}
            />

            {error ? <PText label={error} /> : <Tables columns={column} isLoading={isLoading} data={!data ? [] : data} usePaging={true} />}
        </Wrap>
    )
}

export default BrandPages

const columns = () => {
    const cols = Columns.columnsBrand
    const [id, setId] = React.useState<Brand | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<Brand>[] = [
        cols.id,
        cols.name,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenEdit(true)
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

import React from 'react'
import { categoryService } from 'hooks'
import type { Category } from 'apis'
import { ButtonTooltip, Columns, DeleteConfirm, Icons, PText, Root, SearchInput, Tables, Types } from 'ui'
import { dataListProduct } from '~/navigation'
import { useNavigate } from 'react-router-dom'
import { HStack } from '@chakra-ui/layout'
import { disclousureStore } from '~/store'
import CategoryDetailPages from './category-detail'
import CategoryAddPages from './category-add'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListProduct} backUrl={'/'} activeNum={2}>
        {children}
    </Root>
)

const CategoryPages = () => {
    const navigate = useNavigate()
    const { column, id } = columns()
    const { data, error, isLoading } = categoryService.useGetCategory()
    const { remove } = categoryService.useCategory()
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isOpenEdit && id && <CategoryDetailPages id={id.id} />}
            {isAdd && <CategoryAddPages />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Kategori'}
                onClick={() => handleDelete(String(id?.id))}
            />

            <SearchInput
                labelBtn="Tambah Kategori"
                link={'/category/add'}
                placeholder="Cari Kategori"
                onClick={() => setOpenAdd(true)}
                // onChange={(e) => setQ(e.target.value)}
                onClickBtnExp={(e) => {
                    navigate('/category-import', { replace: true })
                    localStorage.setItem('category-import', JSON.stringify(e))
                }}
            />

            {error ? <PText label={error} /> : <Tables columns={column} isLoading={isLoading} data={!data ? [] : data} usePaging={true} />}
        </Wrap>
    )
}

export default CategoryPages

const columns = () => {
    const cols = Columns.columnsProductCategory
    const [id, setId] = React.useState<Category | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<Category>[] = [
        cols.id,
        cols.name,
        cols.target,
        cols.team,
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
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setIsOpenDeelete(true)
                            setId(v)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id }
}

import React from 'react'
import { regionService } from 'hooks'
import type { Region } from 'apis'
import { ButtonTooltip, Columns, DeleteConfirm, Icons, PagingButton, PText, Root, SearchInput, Tables, Types } from 'ui'
import { dataListLocation } from '~/navigation'
import { HStack } from '@chakra-ui/layout'
import { disclousureStore } from '~/store'
import RegionAddPages from './region-add'
import RegionDetailPages from './region-detail'
import { useNavigate } from 'react-router-dom'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListLocation} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const RegionPages = () => {
    const { column, id } = columns()
    const navigate = useNavigate()
    const { data, error, isLoading, page, setPage, setQ } = regionService.useGetRegion()
    const { remove } = regionService.useRegion()
    const isAdd = disclousureStore((v) => v.isAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isAdd && <RegionAddPages />}
            {isOpenEdit && id && <RegionDetailPages id={id.id} />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Region'}
                onClick={() => handleDelete(String(id?.id))}
            />
            <SearchInput
                labelBtn="Tambah Region"
                link={'/region/add'}
                onClick={() => setOpenAdd(true)}
                placeholder="Cari Region"
                onChange={(e) => setQ(e.target.value)}
                onClickBtnExp={(e) => {
                    navigate('/region-import', { replace: true })
                    localStorage.setItem('region-import', JSON.stringify(e))
                }}
            />
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

export default RegionPages

const columns = () => {
    const cols = Columns.columnsRegion
    const [id, setId] = React.useState<Region | undefined>()
    const [isOpen, setOpen] = React.useState(false)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)

    const column: Types.Columns<Region>[] = [
        cols.id,
        cols.name,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    {/* <Link to={`/region/${v.id}`}> */}
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
                            setIsOpenDeelete(true)
                            setId(v)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id, isOpen, setOpen }
}

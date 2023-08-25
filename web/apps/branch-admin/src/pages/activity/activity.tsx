import React from 'react'
import { Root, Tables, PText, DeleteConfirm, ButtonTooltip, SearchInput, PagingButton, Columns, Types, Icons } from 'ui'
import { activityService, store } from 'hooks'
import { dataListActivity } from '../../navigation'
import type { Activity } from 'apis'
import { HStack } from '@chakra-ui/react'
import { disclousureStore } from '../../store'
import ActivityDetailPages from './activity-detail'
import ActivityAddPages from './activity-add'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Branch" items={dataListActivity} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const ActivityPages = () => {
    const { column, id } = columns()
    const { data, page, setPage, error, isLoading } = activityService.useGetActivity()
    const { remove } = activityService.useActivity()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const isAdd = disclousureStore((v) => v.isAdd)

    const handleDelete = async () => {
        await remove.mutateAsync(`${id?.id}`)
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isOpenEdit && id && <ActivityDetailPages id={id.id} />}
            {isAdd && <ActivityAddPages />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Aktivitas'}
                onClick={handleDelete}
            />
            <SearchInput labelBtn="Tambah Aktivitas" link={'/activity/add'} onClick={() => setOpenAdd(true)} />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables isLoading={isLoading} columns={column} data={isLoading ? [] : data.items} />
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

export default ActivityPages

const columns = () => {
    const cols = Columns.columnsActivity
    const [id, setId] = React.useState<Activity | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const admin = store.useStore((v) => v.admin)

    const column: Types.Columns<Activity>[] = [
        cols.title,
        cols.description,
        cols.videoUrl,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        isDisabled={admin?.roles !== v.creator.roles}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                    />
                    <ButtonTooltip
                        isDisabled={admin?.roles !== v.creator.roles}
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

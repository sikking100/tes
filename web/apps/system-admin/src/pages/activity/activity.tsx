import React from 'react'
import { Root, Tables, PText, DeleteConfirm, SearchInput, PagingButton, Columns, ButtonTooltip, Icons, Types } from 'ui'
import { activityService } from 'hooks'
import type { Activity } from 'apis'
import { dataListActivity } from '~/navigation'
import { HStack } from '@chakra-ui/react'
import { disclousureStore } from '~/store'
import ActivityDetailPages from './activity-detail'
import ActivityAddPages from './activity-add'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListActivity} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const ActivityPages = () => {
    const { column, id } = columns()
    const { data, page, setPage, error, isLoading } = activityService.useGetActivity()
    const { remove } = activityService.useActivity()
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const isAdd = disclousureStore((v) => v.isAdd)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)

    const handleDelete = async () => {
        await remove.mutateAsync(`${id?.id}`)
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isAdd && <ActivityAddPages />}
            {isOpenEdit && id && <ActivityDetailPages id={id.id} />}
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
    // const [isOpen, setOpen] = React.useState(false)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

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
                    {/* <Link to={`/activity/${v.id}`}> */}
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

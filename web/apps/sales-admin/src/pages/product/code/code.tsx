import React from 'react'
import { codeService, store } from 'hooks'
import { DeleteConfirm, Root, SearchInput, Tables, PText, Columns, Types, ButtonTooltip, Icons, PagingButton } from 'ui'
import { listNavigation } from '~/utils'
import { HStack, Text } from '@chakra-ui/layout'
import { Navigate } from 'react-router-dom'
import { Code, Eroles } from 'apis'
import { disclousureStore } from '~/store'
import CodeAddPages from './code-add'
import CodeDetailPages from './code-detail'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const admin = store.useStore((i) => i.admin)
    const list = listNavigation(Number(admin?.roles))
    return (
        <Root appName="Sales" items={list} backUrl={'/'} activeNum={5}>
            {children}
        </Root>
    )
}

const CodePages = () => {
    const admin = store.useStore((i) => i.admin)
    const { column, id } = columns()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenDelete = disclousureStore((v) => v.setIsOpenDelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const { data, error, isLoading, onSetQuery, q } = codeService.useGetCode()
    const { remove } = codeService.useCode()

    const onDelete = async () => {
        await remove.mutateAsync(String(id?.id))
        setIsOpenDelete(false)
    }

    return (
        <Wrap>
            {!admin ? (
                <Text>Loading...</Text>
            ) : admin.roles === Eroles.SALES_ADMIN ? (
                <React.Fragment>
                    {isOpenEdit && id && <CodeDetailPages id={id.id} />}
                    {isAdd && <CodeAddPages />}
                    <DeleteConfirm
                        isLoading={remove.isLoading}
                        isOpen={isOpenDelete}
                        setOpen={() => setIsOpenDelete(false)}
                        onClose={() => setIsOpenDelete(false)}
                        desc={'Kode'}
                        onClick={onDelete}
                    />
                    <SearchInput placeholder="Cari Kode" link="/code/add" onClick={() => setOpenAdd(true)} labelBtn="Tambah Kode" />

                    {error ? (
                        <PText label={error} />
                    ) : (
                        <>
                            <Tables columns={column} isLoading={isLoading} data={!data ? [] : data?.items} usePaging={true} />
                            <PagingButton
                                page={Number(q.page)}
                                nextPage={() => onSetQuery({ page: Number(q.page) + 1 })}
                                prevPage={() => onSetQuery({ page: Number(q.page) - 1 })}
                                disableNext={data?.next === null}
                            />
                        </>
                    )}
                </React.Fragment>
            ) : (
                <Navigate to="/" />
            )}
        </Wrap>
    )
}

export default CodePages

const columns = () => {
    const cols = Columns.columnsCode
    const [id, setId] = React.useState<Code | undefined>()
    const setIsOpenDelete = disclousureStore((v) => v.setIsOpenDelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<Code>[] = [
        cols.id,
        cols.description,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenDelete(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id }
}

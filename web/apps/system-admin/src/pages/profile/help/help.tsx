import React from 'react'
import { DeleteConfirm, PagingButton, PText, Root, SearchInput, Tables } from 'ui'
import { helpService } from 'hooks'
import { dataListProfile } from '~/navigation'
import columnsHelp from './help-columns'
import HelpDetailPages from './help-detail'
import HelpAddPages from './help-add'
import { disclousureStore } from '~/store'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root items={dataListProfile} backUrl={'/'} activeNum={3} appName={'System'}>
        {children}
    </Root>
)

const HelpPages = () => {
    const { column, id } = columnsHelp()
    const { data, page, setPage, setQ, error, isLoading } = helpService.useGetHelp({
        isHelp: true,
    })
    const { remove } = helpService.useHelp()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)

    const onDelete = async () => {
        await remove.mutateAsync(String(id?.id))
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isOpenEdit && id && <HelpDetailPages id={id.id} />}
            {isAdd && <HelpAddPages />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'Bantuan'}
                onClick={onDelete}
            />
            <SearchInput
                labelBtn="Tambah Bantuan"
                onClick={() => setOpenAdd(true)}
                link={'/help/add'}
                placeholder="Cari Bantuan"
                onChange={(e) => setQ(e.target.value)}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables isLoading={isLoading} data={isLoading ? [] : data.items} columns={column} />
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

export default HelpPages

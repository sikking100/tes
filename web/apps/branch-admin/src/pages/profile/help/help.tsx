import React from 'react'
import { Columns, PagingButton, PText, Root, SearchInput, Tables, Types } from 'ui'
import { helpService } from 'hooks'
import { type Help } from 'apis'

export const dataListProfile: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/profile',
        title: 'Kelola Akun',
    },
    {
        id: 2,
        link: '/question',
        title: 'Riwayat Pertanyaan',
    },
    {
        id: 3,
        link: '/help',
        title: 'Pusat Bantuan',
    },
]

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root items={dataListProfile} backUrl={'/'} activeNum={3} appName={'Warehouse'}>
        {children}
    </Root>
)

const HelpPages = () => {
    const { column } = columns()
    const { data, page, setPage, setQ, error, isLoading } = helpService.useGetHelp({
        isHelp: true,
    })

    return (
        <Wrap>
            <SearchInput placeholder="Cari Bantuan" onChange={(e) => setQ(e.target.value)} />

            {error ? <PText label={error} /> : <Tables isLoading={isLoading} data={isLoading ? [] : data.items} columns={column} />}

            <PagingButton
                page={page}
                nextPage={() => setPage(page + 1)}
                prevPage={() => setPage(page - 1)}
                disableNext={data?.next === null}
            />
        </Wrap>
    )
}

export default HelpPages

const columns = () => {
    const cols = Columns.columnsHelp

    const column: Types.Columns<Help>[] = [cols.topic, cols.question, cols.answer, cols.createdAt, cols.updatedAt]

    return { column }
}

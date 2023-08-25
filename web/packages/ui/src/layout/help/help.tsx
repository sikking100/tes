import React from 'react'
import {
    ButtonTooltip,
    Columns,
    Icons,
    PagingButton,
    PText,
    Root,
    SearchInput,
    Tables,
    Types,
} from 'ui'
import { helpService, store } from 'hooks'
import { Eroles, type Help } from 'apis'
import { Link } from 'react-router-dom'

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

const Wrap: React.FC<{ children: React.ReactNode; appName: Types.appName }> = ({
    children,
    appName,
}) => (
    <Root items={dataListProfile} backUrl={`/`} activeNum={3} appName={appName}>
        {children}
    </Root>
)

const HelpPages: React.FC<{ appName: Types.appName }> = ({ appName }) => {
    const { column } = columns()
    const { data, page, setPage, setQ, error, isLoading } =
        helpService.useGetHelp({
            isHelp: true,
        })

    return (
        <Wrap appName={appName}>
            <SearchInput
                placeholder="Cari Bantuan"
                onChange={(e) => setQ(e.target.value)}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <Tables
                    isLoading={isLoading}
                    data={isLoading ? [] : data.items}
                    columns={column}
                />
            )}

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
    const admin = store.useStore((v) => v.admin)
    const cols = Columns.columnsHelp

    let column: Types.Columns<Help>[] = [
        cols.topic,
        cols.question,
        cols.answer,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <Link to={`/help/${v.id}`}>
                    <ButtonTooltip
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                    />
                </Link>
            ),
        },
    ]

    if (admin?.roles !== Eroles.SYSTEM_ADMIN) {
        column = column.filter((v) => v.header !== 'Tindakan')
    }

    return { column }
}

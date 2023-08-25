/* eslint-disable @typescript-eslint/no-non-null-assertion */
import React from 'react'
import { categoryService, store } from 'hooks'
import { ButtonTooltip, Columns, Icons, PText, Root, Tables, Types } from 'ui'
import { listNavigation } from '~/utils'
import { Category, Employee, Eroles } from 'apis'
import CategoryDetailPages from './category-detail'
import { disclousureStore } from '~/store'
import { Box } from '@chakra-ui/react'

const Wrap: React.FC<{ children: React.ReactNode; admin: Employee }> = ({ children, admin }) => {
    const list = listNavigation(Number(admin?.roles))
    return (
        <Root appName="System" items={list} backUrl={'/'} activeNum={2}>
            {children}
        </Root>
    )
}

const CategoryPages = () => {
    const admin = store.useStore((i) => i.admin)
    const { column, id } = columns({ admin: admin! })

    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const { data, error, isLoading } = categoryService.useGetCategory()

    return (
        <Wrap admin={admin!}>
            {isOpenEdit && id && <CategoryDetailPages data={id} />}
            {error ? (
                <PText label={error} />
            ) : (
                <Box>
                    <Tables columns={column} isLoading={isLoading} data={!data ? [] : data} />
                </Box>
            )}
        </Wrap>
    )
}

export default CategoryPages

const columns = (req: { admin: Employee }) => {
    const cols = Columns.columnsProductCategory
    const setEditOpen = disclousureStore((v) => v.setIsOpenEdit)
    const [id, setId] = React.useState<Category | undefined>()

    let column: Types.Columns<Category>[] = [
        cols.id,
        cols.name,
        cols.target,
        cols.team,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <ButtonTooltip
                    label={'Detail'}
                    icon={<Icons.IconDetails color={'gray'} />}
                    onClick={() => {
                        setId(v)
                        setEditOpen(true)
                    }}
                />
            ),
        },
    ]

    if (req.admin?.roles === Eroles.BRANCH_SALES_ADMIN) {
        column = column.filter((v) => v.header !== 'Tindakan')
    }

    return { column, id }
}

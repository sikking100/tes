import React from 'react'
import { Types, ButtonTooltip, Icons, Columns } from 'ui'
import type { ProductTypes } from 'apis'
import { disclousureStore } from '~/store'
import { HStack } from '@chakra-ui/layout'

type QtyTypes = ProductTypes.Product

export default function columnsQty() {
    const [id, setId] = React.useState<QtyTypes | undefined>()
    const [isOpen, setOpen] = React.useState(false)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const cols = Columns.columnsProduct

    const column: Types.Columns<QtyTypes>[] = [
        cols.id,
        cols.name,
        cols.point,
        cols.size,
        cols.brand,
        cols.category,
        cols.team,
        cols.createdAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Transfer'}
                        icon={<Icons.IconsAddOval color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setOpen(true)
                        }}
                    />
                    <ButtonTooltip
                        label={'Gudang'}
                        icon={<Icons.IconDetails color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenEdit(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id, isOpen, setOpen }
}

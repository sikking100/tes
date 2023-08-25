import React from 'react'
import { HStack } from '@chakra-ui/react'
import { Types, ButtonTooltip, Icons, Columns } from 'ui'
import type { Employee } from 'apis'
import { disclousureStore } from '~/store'

export default function columnsCourier() {
    const cols = Columns.columnsUserEmployee
    const [id, setId] = React.useState<Employee | undefined>()
    const [isDetailDelivery, setDetailDelivery] = React.useState(false)
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)
    const setIsOpenDelete = disclousureStore((v) => v.setIsOpenDelete)

    const column: Types.Columns<Employee>[] = [
        cols.id,
        cols.name,
        cols.phone,
        cols.createdAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        onClick={() => {
                            setEdit(true)
                            setId(v)
                        }}
                        label={'Detail'}
                        icon={<Icons.IconDetails color={'gray'} />}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenDelete(true)
                        }}
                    />
                    <ButtonTooltip
                        label={'Pengantaran'}
                        icon={<Icons.IconDelivery color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setDetailDelivery(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id, isDetailDelivery, setDetailDelivery }
}

import React from 'react'
import { HStack } from '@chakra-ui/react'
import { Types, ButtonTooltip, Icons, Columns } from 'ui'
import { Employee } from 'apis'
import { disclousureStore } from '../../store'

export default function columnsUser() {
    const cols = Columns.columnsUserEmployee
    const [id, setId] = React.useState<Employee | undefined>()
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)
    const setDelete = disclousureStore((v) => v.setIsOpenDeelete)

    const column: Types.Columns<Employee>[] = [
        cols.id,
        cols.name,
        cols.location,
        cols.team,
        cols.roles,
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
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setDelete(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id }
}

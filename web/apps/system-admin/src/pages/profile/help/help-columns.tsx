import React from 'react'
import { HStack } from '@chakra-ui/layout'
import { Types, ButtonTooltip, Icons, Columns } from 'ui'
import { disclousureStore } from '~/store'
import { Help } from 'apis'

export default function columnsHelp() {
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const cols = Columns.columnsHelp
    const [id, setId] = React.useState<Help | undefined>()

    const column: Types.Columns<Help>[] = [
        cols.topic,
        cols.question,
        cols.answer,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack pr={5}>
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        label="Delete"
                        icon={<Icons.TrashIcons color="gray" />}
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

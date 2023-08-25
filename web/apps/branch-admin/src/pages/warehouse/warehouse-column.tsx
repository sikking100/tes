import React from 'react'
import { Box, Code, HStack, Text } from '@chakra-ui/layout'
import { Types, ButtonTooltip, Icons } from 'ui'
import { Warehouse } from 'apis'
import { disclousureStore } from '../../store'
import { CheckIcon } from '@chakra-ui/icons'

type WarehouseTypes = Warehouse

export default function columnsWarehouse() {
    const [id, setId] = React.useState<WarehouseTypes | undefined>()
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)

    const column: Types.Columns<WarehouseTypes>[] = [
        {
            header: 'ID',
            render: (v) => <Text>{v.id}</Text>,
        },
        {
            header: 'Nama',
            render: (v) => (
                <HStack>
                    <Text>{v.name}</Text>
                    {v.isDefault && <CheckIcon color="green.500" />}
                </HStack>
            ),
        },
        {
            header: 'Alamat',
            render: (v) => <Text>{v.address.name}</Text>,
        },
        {
            header: 'Nomor HP',
            render: (v) => <Text>{v.phone}</Text>,
        },

        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setIsOpenEdit(true)
                        }}
                    />

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

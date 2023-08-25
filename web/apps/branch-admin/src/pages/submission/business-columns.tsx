import React from 'react'
import { Avatar, HStack, ListItem, Text, UnorderedList } from '@chakra-ui/react'
import { Types, ButtonTooltip, Icons } from 'ui'
import { CustomerApply } from 'apis'
import { disclousureStore } from '../../store'

export default function columnsBusiness() {
    const [id, setId] = React.useState<CustomerApply | undefined>()
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)

    const column: Types.Columns<CustomerApply>[] = [
        {
            header: 'Nama Pemilik',
            render: (v) => (
                <HStack>
                    <Avatar src={v.customer.imageUrl} />
                    <Text>{v.customer.name}</Text>
                </HStack>
            ),
        },
        {
            header: 'Nama PIC',
            render: (v) => <Text>{v.pic.name}</Text>,
        },
        {
            header: 'Alamat',
            render: (v) => (
                <>
                    {
                        <UnorderedList>
                            {v.address.map((i, k) => (
                                <ListItem key={k}>{i.name}</ListItem>
                            ))}
                        </UnorderedList>
                    }
                </>
            ),
        },
        {
            header: 'Tindakan',
            render: (v) => {
                return (
                    <>
                        <ButtonTooltip
                            label={'Detail'}
                            icon={<Icons.IconDetails color={'gray'} />}
                            onClick={() => {
                                setEdit(true)
                                setId(v)
                            }}
                        />
                    </>
                )
            },
        },
    ]

    return { column, id }
}

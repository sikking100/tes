import { ListItem, Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
import { Employee } from 'apis'
import { StackAvatar } from '../stack-avatar'
import { splitText } from '../utils/shared'
import { UnorderedList } from '@chakra-ui/react'
import { entity } from '../utils'

type UserTypes = Omit<
    Employee,
    | 'imageUrl'
    | 'createdById'
    | 'regionId'
    | 'branch_'
    | 'region_'
    | 'fcmToken'
    | 'image_'
>
type Keys = keyof UserTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Employee>
}

export const columnsUserEmployee: ColumnsTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },

    name: {
        header: 'Nama',
        render: (v) => (
            <StackAvatar
                imageUrl={`${v.imageUrl}`}
                name={splitText(v.name, 15)}
            />
        ),
    },
    location: {
        header: 'Lokasi',
        render: (v) => (
            <Text as="span">
                {v.location ? (
                    <UnorderedList>
                        <ListItem>{v.location.name}</ListItem>
                    </UnorderedList>
                ) : (
                    '-'
                )}
            </Text>
        ),
    },
    team: {
        header: 'Tim',
        render: (v) => (
            <Text>
                {String(v.team) === '0' ? '-' : entity.team(String(v.team))}
            </Text>
        ),
    },
    roles: {
        header: 'Roles',
        render: (v) => <Text>{entity.roles(v.roles)}</Text>,
    },
    phone: {
        header: 'Nomor HP',
        render: (v) => <Text>{v.phone}</Text>,
    },
    email: {
        header: 'Email',
        render: (v) => <Text>{splitText(v.email, 15)}</Text>,
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}

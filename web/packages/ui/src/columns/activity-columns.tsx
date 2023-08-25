import { Text, Box } from '@chakra-ui/layout'
import { Avatar } from '@chakra-ui/avatar'
import { Types, Shared } from 'ui'
import type { Activity } from 'apis'
import { StackAvatar } from '../stack-avatar'
import { splitText } from '../utils/shared'

type ActivityTypes = Omit<Activity, 'image_' | 'comment' | 'commentCount'>
type Keys = keyof ActivityTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Activity>
}

export const columnsActivity: ColumnsTypes = {
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Box>{Shared.FormatDateToString(v.createdAt)}</Box>,
    },
    creator: {
        header: 'Dibuat Oleh',
        render: (v) => (
            <StackAvatar imageUrl={v.creator.imageUrl} name={v.creator.name} />
        ),
    },
    description: {
        header: 'Deskripsi',
        render: (v) => <Box>{splitText(v.description, 20)}</Box>,
    },
    id: {
        header: 'ID',
        render: (v) => <Box>{v.id}</Box>,
    },
    imageUrl: {
        header: 'Gambar',
        render: (v) => <Avatar size="sm" src={v.imageUrl} />,
    },
    title: {
        header: 'Judul',
        render: (v) => <Box>{splitText(v.title, 20)}</Box>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Box>{Shared.FormatDateToString(v.updatedAt)}</Box>,
    },
    videoUrl: {
        header: 'Video URL',
        render: (v) => (
            <Box textDecor={v.videoUrl !== '-' ? 'underline' : ''}>
                {v.videoUrl || '-'}
            </Box>
        ),
    },
}

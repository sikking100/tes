import { Box, Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
import { StackAvatar } from '../stack-avatar'
import { Help } from 'apis'

type HelpType = Omit<Help, 'id'>
type Keys = keyof HelpType
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Help>
}

export const columnsHelp: ColumnsTypes = {
    creator: {
        header: 'Dibuat Oleh',
        render: (v) => (
            <StackAvatar imageUrl={v.creator.imageUrl} name={v.creator.name} />
        ),
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
    answer: {
        header: 'Jawaban',
        render: (v) => <Text>{v.answer}</Text>,
    },
    question: {
        header: 'Pertanyaan',
        render: (v) => <Text>{v.question}</Text>,
    },
    topic: {
        header: 'Topik',
        render: (v) => <Text>{v.topic}</Text>,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
}

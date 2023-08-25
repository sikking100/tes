import { Box, Text } from '@chakra-ui/layout'
import { Types, Shared } from 'ui'
import { StackAvatar } from '../stack-avatar'
import { Recipe } from 'apis'

type RecipeTypes = Omit<Recipe, 'image' | 'imageUrl' | 'image_'>
type Keys = keyof RecipeTypes
type ColumnsTypes = {
    [key in Keys]: Types.Columns<Recipe>
}

export const columnsRecipe: ColumnsTypes = {
    id: {
        header: 'ID',
        render: (v) => <Text>{v.id}</Text>,
    },
    category: {
        header: 'Kategori',
        render: (v) => <Text>{v.category}</Text>,
    },
    description: {
        header: 'Deskripsi',
        render: (v) => <Text>{Shared.splitText(v.description, 50)}</Text>,
    },
    title: {
        header: 'Judul',
        render: (v) => <StackAvatar imageUrl={v.imageUrl} name={v.title} />,
    },
    updatedAt: {
        header: 'Tanggal Diperbarui',
        render: (v) => <Text>{Shared.FormatDateToString(v.updatedAt)}</Text>,
    },
    createdAt: {
        header: 'Tanggal Dibuat',
        render: (v) => <Text>{Shared.FormatDateToString(v.createdAt)}</Text>,
    },
}

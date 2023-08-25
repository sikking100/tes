import React from 'react'
import {
    ButtonTooltip,
    Columns,
    DeleteConfirm,
    Icons,
    PagingButton,
    PText,
    Root,
    SearchInput,
    Tables,
    Types,
} from 'ui'
import { dataListRecipe } from '~/navigation'
import { recipeService } from 'hooks'
import { HStack } from '@chakra-ui/layout'
import { Recipe } from 'apis'
import RecipeDetailPages from './recipe-detail'
import RecipeAddPages from './recipe-add'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Sales" items={dataListRecipe} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const RecipePages = () => {
    const [isOpenCreate, setOpenCreate] = React.useState(false)
    const { column, id, isOpen, setOpen, isOpenEdit, setOpenEdit } = columns()
    const { data, page, setPage, setQ, error, isLoading } =
        recipeService.useGetRecipe()
    const { remove } = recipeService.useRecipe()

    const handleDelete = () => {
        remove.mutateAsync(String(id?.id))
        setOpen(false)
    }

    return (
        <Wrap>
            {isOpenCreate && (
                <RecipeAddPages isOpen={isOpenCreate} setOpen={setOpenCreate} />
            )}

            {isOpenEdit && (
                <RecipeDetailPages
                    setOpen={setOpenEdit}
                    isOpen={isOpenEdit}
                    data={id!}
                />
            )}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpen}
                setOpen={() => setOpen(false)}
                onClose={() => setOpen(false)}
                desc={'Resep'}
                onClick={handleDelete}
            />

            <SearchInput
                placeholder="Cari Resep"
                labelBtn="Tambah Resep"
                link="#"
                onClick={() => setOpenCreate(true)}
                onChange={(e) => setQ(e.target.value)}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables
                        isLoading={isLoading}
                        columns={column}
                        data={isLoading ? [] : data.items}
                    />
                    <PagingButton
                        page={page}
                        nextPage={() => setPage(page + 1)}
                        prevPage={() => setPage(page - 1)}
                        disableNext={data?.next === null}
                    />
                </>
            )}
        </Wrap>
    )
}

export default RecipePages

const columns = () => {
    const cols = Columns.columnsRecipe
    const [id, setId] = React.useState<Recipe | undefined>()
    const [isOpen, setOpen] = React.useState(false)
    const [isOpenEdit, setOpenEdit] = React.useState(false)

    const column: Types.Columns<Recipe>[] = [
        cols.title,
        cols.category,
        cols.description,
        cols.createdAt,
        cols.updatedAt,
        {
            header: 'Tindakan',
            render: (v) => (
                <HStack>
                    <ButtonTooltip
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setOpenEdit(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        label={'Delete'}
                        icon={<Icons.TrashIcons color={'gray'} />}
                        onClick={() => {
                            setId(v)
                            setOpen(true)
                        }}
                    />
                </HStack>
            ),
        },
    ]

    return { column, id, isOpen, setOpen, isOpenEdit, setOpenEdit }
}

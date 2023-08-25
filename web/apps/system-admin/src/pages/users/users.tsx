import React from 'react'
import {
    Tables,
    SearchInput,
    Root,
    PText,
    DeleteConfirm,
    PagingButton,
    Columns,
    Types,
    ButtonTooltip,
    Icons,
    FormSelects,
    ButtonForm,
} from 'ui'
import { employeeService } from 'hooks'
import { Eroles, type Employee, type SelectsTypes, Branch } from 'apis'
import { dataListAccount } from '~/navigation'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import {
    Box,
    HStack,
    IconButton,
    Popover,
    PopoverBody,
    PopoverCloseButton,
    PopoverContent,
    PopoverHeader,
    PopoverTrigger,
    Portal,
    Tooltip,
} from '@chakra-ui/react'
import { Searchs } from './function'
import { disclousureStore } from '~/store'
import UserDetailPages from './user-details'
import UserAddPages from './users-add'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListAccount} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const UserPages = () => {
    const navigate = useNavigate()
    const [openFilter, setOpenFilter] = React.useState(false)
    const [searchParams] = useSearchParams()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const isOpenDelete = disclousureStore((v) => v.isOpenDelete)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    const { data, page, setPage, setQ, error, isLoading } = employeeService.useGetEmployee({
        query: searchParams.get('q') ? `${searchParams.get('q')}` : undefined,
    })
    const { remove } = employeeService.useEmployee()
    const { column, id } = columns()

    const handleDelete = async (id: string) => {
        await remove.mutateAsync(id)
        setIsOpenDeelete(false)
    }

    return (
        <Wrap>
            {isOpenEdit && id && <UserDetailPages id={id.id} />}
            {isAdd && <UserAddPages />}
            <HStack w={'fit-content'}>
                <SearchInput
                    labelBtn="Tambah Akun"
                    link={'/account/add'}
                    onClick={() => setOpenAdd(true)}
                    placeholder="Cari akun berdasarkan nama, nomor hp .."
                    onChange={(e) => setQ(e.target.value)}
                    onClickBtnExp={(e) => {
                        navigate('/import-account', { replace: true })
                        localStorage.setItem('user-import', JSON.stringify(e))
                    }}
                />
                <FilterUser isOpen={openFilter} onOpen={setOpenFilter} />
            </HStack>

            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpenDelete}
                setOpen={() => setIsOpenDeelete(false)}
                onClose={() => setIsOpenDeelete(false)}
                desc={'User'}
                onClick={() => handleDelete(String(id?.id))}
            />

            {error ? (
                <PText label={error} />
            ) : (
                <>
                    <Tables columns={column} isLoading={isLoading} data={isLoading ? [] : data?.items || []} usePaging={true} />
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

export default UserPages

const columns = () => {
    const cols = Columns.columnsUserEmployee
    const [id, setId] = React.useState<Employee | undefined>()
    const setIsOpenDeelete = disclousureStore((v) => v.setIsOpenDeelete)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)

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
                        label={'Edit'}
                        icon={<Icons.PencilIcons color={'gray'} />}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(v)
                        }}
                    />
                    <ButtonTooltip
                        isDisabled={v.roles === 17}
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

interface FilterUserProps {
    isOpen: boolean
    onOpen: React.Dispatch<React.SetStateAction<boolean>>
}

const FilterUser: React.FC<FilterUserProps> = (props) => {
    const { isOpen, onOpen } = props
    const navigate = useNavigate()
    const firstFieldRef = React.useRef(null)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { control, getValues, watch } = useForm<any>()
    const type = watch('type')

    const searchBranch = Searchs('branch')

    const optionsTypeFilter: SelectsTypes[] = [
        {
            label: 'Roles',
            value: 'roles',
        },
        {
            label: 'Team',
            value: 'team',
        },
        {
            label: 'Cabang',
            value: 'branch',
        },
    ]

    const checkCurrentType = () => {
        if (watch('type.value') === 'branch') return 'branch'
        if (watch('type.value') === 'roles') return 'roles'
        if (watch('type.value') === 'team') return 'team'
        return ''
    }

    const onSubmit = () => {
        let querys = ''
        if (checkCurrentType() === 'team') {
            const q = getValues('query.value') as SelectsTypes
            if (q) querys = `${q}`
            else querys = ''
        }
        if (checkCurrentType() === 'branch') {
            const q = JSON.parse(getValues('query.value')) as Branch
            if (q) querys = `${q.id}`
            else querys = ''
        }
        if (checkCurrentType() === 'roles') {
            const q = getValues('query.value') as SelectsTypes
            if (q) querys = `${q}`
            else querys = ''
        }

        const uri = `/account?q=${querys}`

        navigate(uri)
        onOpen(false)
    }

    const rolesData = [
        {
            value: Eroles.SYSTEM_ADMIN,
            label: 'System Admin',
        },
        {
            value: Eroles.FINANCE_ADMIN,
            label: 'Finance Admin',
        },
        {
            value: Eroles.SALES_ADMIN,
            label: 'Sales Admin',
        },
        {
            value: Eroles.WAREHOUSE_ADMIN,
            label: 'Warehouse Admin',
        },
        {
            value: Eroles.BRANCH_ADMIN,
            label: 'Branch Admin',
        },
        {
            value: Eroles.BRANCH_FINANCE_ADMIN,
            label: 'Branch Finance Admin',
        },
        {
            value: Eroles.BRANCH_SALES_ADMIN,
            label: 'Branch Sales Admin',
        },
        {
            value: Eroles.BRANCH_WAREHOUSE_ADMIN,
            label: 'Branch Warehouse Admin',
        },
        {
            value: Eroles.DIREKTUR,
            label: 'Direktur',
        },
        {
            value: Eroles.GENERAL_MANAGER,
            label: 'General Manager',
        },
        {
            value: Eroles.NASIONAL_SALES_MANAGER,
            label: 'Nasional Sales Manager',
        },
        {
            value: Eroles.REGIONAL_MANAGER,
            label: 'Regional Manager',
        },
        {
            value: Eroles.AREA_MANAGER,
            label: 'Area Manager',
        },
        {
            value: Eroles.SALES,
            label: 'Sales',
        },
        {
            value: Eroles.COURIER,
            label: 'Courier',
        },
    ]

    return (
        <Popover
            isOpen={isOpen}
            initialFocusRef={firstFieldRef}
            onOpen={() => onOpen(true)}
            onClose={() => onOpen(false)}
            placement="bottom"
            size={'xl'}
        >
            <>
                <PopoverTrigger>
                    <Tooltip label="Filter">
                        <IconButton
                            onClick={() => onOpen(true)}
                            bg="red.200"
                            aria-label="select date"
                            icon={<Icons.IconFilter color={'#fff'} />}
                            mt={'-10px !important'}
                        />
                    </Tooltip>
                </PopoverTrigger>
                <Portal>
                    <PopoverContent width={'400px'}>
                        <PopoverHeader fontWeight={'semibold'}>Filter Data User</PopoverHeader>
                        <PopoverCloseButton />
                        <PopoverBody>
                            <form>
                                <p style={{ display: 'none' }}>{JSON.stringify(type)}</p>
                                <Box experimental_spaceY={3}>
                                    <FormSelects
                                        control={control}
                                        label={'type'}
                                        options={optionsTypeFilter}
                                        placeholder={'Pilih Jenis Filter'}
                                        title={'Pilih Filter'}
                                    />

                                    {watch('type.value') === 'roles' && (
                                        <FormSelects
                                            control={control}
                                            label={'query'}
                                            options={rolesData}
                                            placeholder={'Pilih Roles'}
                                            title={'Roles'}
                                        />
                                    )}

                                    {watch('type.value') === 'team' && (
                                        <FormSelects
                                            control={control}
                                            label={'query'}
                                            options={['FOOD SERVICE', 'RETAIL'].map((i) => ({
                                                value: i === 'FOOD SERVICE' ? 1 : 2,
                                                label: i,
                                            }))}
                                            placeholder={'Pilih Tim'}
                                            title={'Tim'}
                                        />
                                    )}

                                    {watch('type.value') === 'branch' && (
                                        <FormSelects
                                            async={true}
                                            control={control}
                                            label={'query'}
                                            loadOptions={searchBranch}
                                            placeholder={'Pilih Cabang'}
                                            title={'Cabang'}
                                        />
                                    )}
                                </Box>

                                <ButtonForm
                                    type="button"
                                    isLoading={false}
                                    label="Filter"
                                    onClick={onSubmit}
                                    onClose={() => onOpen(false)}
                                />
                            </form>
                        </PopoverBody>
                    </PopoverContent>
                </Portal>
            </>
        </Popover>
    )
}

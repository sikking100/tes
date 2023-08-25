import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, FormSelects, ImagePick, Modals, entity } from 'ui'
import { Eroles, type CreateEmployee } from 'apis'
import { employeeService, usePickImage, store } from 'hooks'
import { TYPE_TEAM } from '~/utils/roles'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '~/utils/shared'
import { disclousureStore } from '~/store'
import { useSearchParams } from 'react-router-dom'

export const ROLES_ADMIN = [
    { value: `${Eroles.BRANCH_FINANCE_ADMIN}`, label: 'Finance Admin' },
    { value: `${Eroles.WAREHOUSE_ADMIN}`, label: 'Warehouse Admin' },
    { value: `${Eroles.BRANCH_SALES_ADMIN}`, label: 'Sales Admin' },
    { value: `${Eroles.SALES}`, label: 'Sales Staf' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
]

const UserAddPages: React.FC<{ dRoles: number }> = ({ dRoles }: { dRoles: number }) => {
    const admin = store.useStore((v) => v.admin)
    const [_, setSearchParams] = useSearchParams()

    const { create } = employeeService.useEmployee()
    const { preview, onSelectFile, selectedFile } = usePickImage('user')
    const isAdd = disclousureStore((v) => v.isAdd)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const {
        handleSubmit,
        register,
        control,
        watch,
        formState: { errors },
    } = useForm<CreateEmployee>({
        defaultValues: {
            roles: entity.roles(dRoles) as unknown as number,
        },
    })

    const onSubmit: SubmitHandler<CreateEmployee> = async (data) => {
        let teams = Number(data.team_?.value || 0)

        if (!binding()) {
            teams = 0
        }

        const ReqData: CreateEmployee = {
            id: data.id,
            name: data.name,
            email: data.email,
            phone: data.phone,
            team: teams,
            roles: dRoles,
            location: {
                id: admin?.location.id ?? '',
                name: admin?.location?.name ?? '',
                type: admin?.location.type ?? 1,
            },
            image_: selectedFile,
        }

        await create.mutateAsync(ReqData)
        setOpenAdd(false)
        const chekcRolesV =
            ReqData.roles === Eroles.BRANCH_WAREHOUSE_ADMIN
                ? 0
                : ReqData.roles === Eroles.BRANCH_FINANCE_ADMIN
                ? 1
                : ReqData.roles === Eroles.BRANCH_SALES_ADMIN
                ? 2
                : ReqData.roles === Eroles.AREA_MANAGER
                ? 3
                : ReqData.roles === Eroles.SALES
                ? 4
                : 0
        setSearchParams({ set: 'type', id: `${chekcRolesV}` })
    }

    const binding = () => {
        let is = false
        const wRoles = Number(dRoles)
        if (Number(wRoles) === Eroles.AREA_MANAGER) is = true
        if (Number(wRoles) === Eroles.SALES) is = true
        return is
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'5xl'} title={'Tambah Akun'}>
            <p style={{ display: 'none' }}>{JSON.stringify(watch('roles_'))}</p>
            <form onSubmit={handleSubmit(onSubmit)}>
                <SimpleGrid columns={2} columnGap={5} mb={3}>
                    <Box experimental_spaceY={'10px'}>
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto"
                                boxSize={150}
                                idImage="npwp"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                        <FormControls
                            label="id"
                            register={register}
                            title={'ID'}
                            errors={errors.id?.message}
                            required={'ID User tidak boleh kosong'}
                            pattern={{
                                value: RegExSpescialChar,
                                message: 'ID hanya boleh huruf dan angka',
                            }}
                        />
                        <FormControls
                            label="name"
                            register={register}
                            title={'Nama'}
                            errors={errors.name?.message}
                            required={'Nama tidak boleh kosong'}
                        />
                        <FormControls
                            label="phone"
                            title={'Nomor HP'}
                            register={register}
                            errors={errors.phone?.message}
                            pattern={{
                                value: RegExPhoneNumber,
                                message: 'Nomor HP tidak valid',
                            }}
                            required={'Nomor HP tidak boleh kosong'}
                        />
                    </Box>

                    <Box experimental_spaceY={'10px'}>
                        <FormControls
                            readOnly={true}
                            label="roles"
                            register={register}
                            title={'Roles'}
                            errors={errors.name?.message}
                            required={'Nama tidak boleh kosong'}
                        />

                        <FormControls
                            label="email"
                            title={'Email'}
                            register={register}
                            errors={errors.email?.message}
                            required={'Email tidak boleh kosong'}
                            pattern={{
                                value: RegExEmail,
                                message: 'Masukkan email yang valid',
                            }}
                        />
                        {binding() ? (
                            <FormSelects
                                control={control}
                                label={'team_'}
                                options={TYPE_TEAM.filter((v) => v.label !== '-')}
                                placeholder={'Pilih Tim'}
                                title={'Tim'}
                                required={'Tim Tidak Boleh Kosong'}
                            />
                        ) : null}
                    </Box>
                </SimpleGrid>

                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default UserAddPages

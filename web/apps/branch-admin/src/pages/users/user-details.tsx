import React, { useState } from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, FormSelects, ImagePick, LoadingForm, Modals, PText } from 'ui'
import { TYPE_TEAM } from '../../utils/roles'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '../../utils/shared'
import { employeeService, usePickImage } from 'hooks'
import { CreateEmployee, Eroles, SelectsTypes } from 'apis'
import { setRole } from './function'
import { disclousureStore } from '../../store'
import { useSearchParams } from 'react-router-dom'

export const ROLES_ADMIN = [
    { value: `${Eroles.BRANCH_FINANCE_ADMIN}`, label: 'Finance Admin' },
    { value: `${Eroles.BRANCH_WAREHOUSE_ADMIN}`, label: 'Warehouse Admin' },
    { value: `${Eroles.BRANCH_SALES_ADMIN}`, label: 'Sales Admin' },
    { value: `${Eroles.SALES}`, label: 'Sales Staf' },
    { value: `${Eroles.AREA_MANAGER}`, label: 'Area Manager' },
]

const UserDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage()
    const { create } = employeeService.useEmployee()
    const { data, error, isLoading } = employeeService.useGetByIdEmployee(id)
    const [roles, setRoles] = useState<SelectsTypes[]>([])
    const [loading, setIsLoading] = React.useState(true)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const [_, setSearchParams] = useSearchParams()

    const {
        handleSubmit,
        register,
        control,
        reset,
        watch,
        getValues,
        formState: { errors },
    } = useForm<CreateEmployee>()

    React.useEffect(() => {
        if (data) {
            setPreview(data?.imageUrl)
            setDefault()
        }
    }, [isLoading])

    React.useEffect(() => {
        if (watch('team_')) {
            const team = getValues('team_.value')
            setRole({ team: team, setRoles })
        }
    }, [watch('team_')])

    const setDefault = async () => {
        const rolesName = `${data?.roles}`
        const teamName = `${data?.team}`
        const findRoles = ROLES_ADMIN.find((v) => v.value === rolesName)
        const findTeam = TYPE_TEAM.find((i) => i.value === teamName)

        reset({
            ...data,
            roles_: findRoles,
            team_: findTeam,
        })

        setIsLoading(false)
    }

    const onSubmit: SubmitHandler<CreateEmployee> = async (data) => {
        if (!data.roles_) return
        const teams = Number(data.team_?.value || 0)
        const roles = Number(data.roles_?.value)

        const ReqData: CreateEmployee = {
            id: data.id,
            phone: data.phone,
            name: data.name,
            email: data.email,
            roles: roles,
            image_: selectedFile,
            team: teams,
            location: {
                id: `${data?.location?.id}`,
                name: `${data?.location?.name}`,
                type: Number(data?.location?.type),
            },
        }

        await create.mutateAsync(ReqData)
        setIsOpenEdit(false)
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
        const wRoles = Number(watch('roles_.value'))
        if (wRoles === Eroles.AREA_MANAGER) is = true
        if (wRoles === Eroles.SALES) is = true
        return is
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'4xl'} title="Detail Akun">
            {error ? (
                <PText label={error} />
            ) : loading ? (
                <LoadingForm />
            ) : (
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
                            <FormSelects
                                control={control}
                                defaultValue={getValues('roles_')}
                                label={'roles_'}
                                options={roles}
                                placeholder={'Pilih Roles'}
                                required={'Roles tidak boleh kosong'}
                                title={'Roles'}
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
                            {binding() && (
                                <FormSelects
                                    control={control}
                                    defaultValue={getValues('team_')}
                                    label={'team_'}
                                    options={TYPE_TEAM.filter((v) => v.label !== '-')}
                                    placeholder={'Pilih Tim'}
                                    title={'Tim'}
                                    required={'Tim Tidak Boleh Kosong'}
                                />
                            )}
                        </Box>
                    </SimpleGrid>

                    <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setIsOpenEdit(false)} />
                </form>
            )}
        </Modals>
    )
}

export default UserDetailPages

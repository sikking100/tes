import React, { useState } from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { VisuallyHidden } from '@chakra-ui/visually-hidden'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, entity, FormControls, FormSelects, ImagePick, Modals, TextWarning } from 'ui'
import { Eroles, type Branch, type CreateEmployee, type Location, type Region, type SelectsTypes, Eteam } from 'apis'
import { employeeService, usePickImage } from 'hooks'
import { ROLES_ADMIN, ROLES_FOOD_SERVICE, ROLES_RETAIL } from '~/utils/roles'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '~/utils/shared'
import { Searchs } from './function'
import { disclousureStore } from '~/store'

type ReqTypes = CreateEmployee & {
    newTeam?: SelectsTypes
    newBranch?: SelectsTypes
    newRoles?: SelectsTypes
    newRegion?: SelectsTypes
}

const TYPE_TEAM = [
    { value: '0', label: 'Admin' },
    { value: `${Eteam.FOOD}`, label: 'Food Service' },
    { value: `${Eteam.RETAIL}`, label: 'Retail' },
]

const UserAddPages = () => {
    const isAdd = disclousureStore((v) => v.isAdd)
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const [roles, setRoles] = useState<SelectsTypes[]>([])
    const { preview, onSelectFile, selectedFile } = usePickImage('user')
    const { create } = employeeService.useEmployee()
    const bySearchBranch = Searchs('branch')
    const bySearchRegion = Searchs('region')

    const {
        handleSubmit,
        register,
        control,
        setValue,
        watch,
        getValues,
        formState: { errors },
    } = useForm<ReqTypes>({})

    React.useEffect(() => {
        const rolesAdmiRemoved = ROLES_ADMIN.filter((v) => {
            return (
                v.value !== `${Eroles.BRANCH_FINANCE_ADMIN}` &&
                v.value !== `${Eroles.BRANCH_SALES_ADMIN}` &&
                v.value !== `${Eroles.BRANCH_WAREHOUSE_ADMIN}`
            )
        })
        if (watch('newTeam.value')) {
            const team = getValues('newTeam.value')
            if (team === entity.Team.FOOD_SERVICE) {
                const filter = ROLES_FOOD_SERVICE.filter((v) => {
                    return v.value !== `${Eroles.SALES}` && v.value !== `${Eroles.AREA_MANAGER}`
                })
                setRoles(filter)
            } else if (team === entity.Team.RETAIL) {
                const filter = ROLES_RETAIL.filter((v) => {
                    return v.value !== `${Eroles.SALES}` && v.value !== `${Eroles.AREA_MANAGER}`
                })
                setRoles(filter)
            } else {
                setRoles(rolesAdmiRemoved)
            }
        } else {
            setRoles(rolesAdmiRemoved)
        }
    }, [watch('newTeam'), roles])

    React.useEffect(() => {
        if (watch('newRoles.value')) {
            setValue('roles', Number(getValues('newRoles.value')))
        }
    }, [watch('newRoles.value')])

    const onSubmit: SubmitHandler<ReqTypes> = async (data) => {
        let team = 0
        let location: Location | null = null
        const roles = Number(data.newRoles?.value)

        if (getValues('newRegion')) {
            const region = JSON.parse(getValues('newRegion.value')) as Region
            location = {
                id: region.id,
                name: region.name,
                type: 1,
            }
        }

        if (getValues('newBranch')) {
            const branch = JSON.parse(getValues('newBranch.value')) as Branch
            location = {
                id: branch.id,
                name: branch.name,
                type: 2,
            }
        }

        if (getValues('newTeam.value')) {
            team = Number(getValues('newTeam.value'))
        }

        const rolesNeedLocation = [Eroles.BRANCH_ADMIN, Eroles.REGIONAL_MANAGER]
        if (!rolesNeedLocation.includes(roles)) location = null

        const ReqData: CreateEmployee = {
            name: data.name,
            email: data.email,
            phone: data.phone,
            id: data.id,
            team: team,
            location: location,
            roles: Number(data.newRoles?.value),
            image_: selectedFile,
        }

        await create.mutateAsync(ReqData)
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'5xl'} title="Tambah Akun">
            <form onSubmit={handleSubmit(onSubmit)}>
                <VisuallyHidden>{JSON.stringify(watch('newRoles'))}</VisuallyHidden>
                <SimpleGrid columns={2} columnGap={5} mb={3}>
                    <Box experimental_spaceY={'10px'}>
                        <Box w={'fit-content'} h={'fit-content'}>
                            <ImagePick
                                title="Foto"
                                boxSize={150}
                                idImage="foto"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                        <FormControls
                            label="id"
                            register={register}
                            title={'ID'}
                            errors={errors.id?.message}
                            required={'ID tidak boleh kosong'}
                            pattern={{
                                value: RegExSpescialChar,
                                message: 'ID hanya boleh huruf dan angka',
                            }}
                        />
                        <TextWarning />

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
                            label={'newTeam'}
                            defaultValue={TYPE_TEAM[0]}
                            options={TYPE_TEAM}
                            placeholder={'Pilih Tim Leader'}
                            title={'Tim'}
                        />
                        {roles.length ? (
                            <FormSelects
                                control={control}
                                label={'newRoles'}
                                options={roles}
                                placeholder={'Pilih Roles'}
                                required={'Roles tidak boleh kosong'}
                                title={'Roles'}
                            />
                        ) : null}

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

                        {watch('newRoles.value') === `${Eroles.REGIONAL_MANAGER}` ? (
                            <FormSelects
                                async
                                loadOptions={bySearchRegion}
                                label="newRegion"
                                title={'Region'}
                                placeholder="Pilih Region"
                                control={control}
                                errors={errors.newRegion?.value?.message}
                            />
                        ) : watch('newRoles.value') === `${Eroles.BRANCH_ADMIN}` ? (
                            <FormSelects
                                async
                                loadOptions={bySearchBranch}
                                label="newBranch"
                                title={'Cabang'}
                                placeholder="Pilih Cabang"
                                control={control}
                                errors={errors.newBranch?.value?.message}
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

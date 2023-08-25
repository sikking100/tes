import React, { useState } from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, entity, FormControls, FormSelects, ImagePick, LoadingForm, Modals, PText, TextWarning } from 'ui'
import { type Branch, type CreateEmployee, type ECategory, type Location, type Region, type SelectsTypes, Eroles } from 'apis'
import { employeeService, usePickImage } from 'hooks'
import { ROLES_ADMIN, ROLES_EMPLOYEE, ROLES_FOOD_SERVICE, ROLES_RETAIL } from '~/utils/roles'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '~/utils/shared'
import { Searchs } from './function'
import { disclousureStore } from '~/store'
import { VisuallyHidden } from '@chakra-ui/react'

type ReqTypes = CreateEmployee & {
    newTeam?: SelectsTypes
    newBranch?: SelectsTypes
    newRoles?: SelectsTypes
    newRegion?: SelectsTypes
    newCategory?: SelectsTypes[]
}

const DefaultSelect = { label: '-', value: '-' }

const TYPE_TEAM = [
    { value: '0', label: 'Admin' },
    { value: entity.Team.FOOD_SERVICE, label: 'Food Service' },
    { value: entity.Team.RETAIL, label: 'Retail' },
]

const UserDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const [isLoading, setIsLoading] = React.useState(true)
    const [roles, setRoles] = useState<SelectsTypes[]>([])
    const [locationDefault, setLocationDefault] = useState<SelectsTypes[]>([])
    const [locationDefaultBranch, setLocationBranchDefault] = useState<SelectsTypes[]>([])
    const { preview, onSelectFile, selectedFile, setPreview } = usePickImage('user')
    const { createUpdate } = employeeService.useEmployee()
    const { data, error } = employeeService.useGetByIdEmployee(id)
    const bySearchBranch = Searchs('branch')
    const bySearchRegion = Searchs('region')

    const {
        handleSubmit,
        register,
        control,
        setValue,
        reset,
        watch,
        getValues,
        formState: { errors },
    } = useForm<ReqTypes>({
        defaultValues: { newTeam: DefaultSelect, newBranch: DefaultSelect },
    })

    const setDefault = async () => {
        const rolesName = `${data?.roles}`
        const teamName = `${data?.team}`
        const location = `${data?.location?.name}`

        if (teamName === '0') {
            const findRoles = ROLES_ADMIN.find((v) => v.value === rolesName)
            const findRole = ROLES_EMPLOYEE.find((v) => v.value === rolesName)
            setValue('newRoles', findRoles || findRole)
        }
        if (teamName === `${entity.Team.FOOD_SERVICE}`) {
            const findRoles = ROLES_FOOD_SERVICE.find((v) => v.value === rolesName)
            const findRole = ROLES_EMPLOYEE.find((v) => v.value === rolesName)
            setValue('newRoles', findRoles || findRole)
        }
        if (teamName === `${entity.Team.RETAIL}`) {
            const findRoles = ROLES_RETAIL.find((v) => v.value === rolesName)
            const findRole = ROLES_EMPLOYEE.find((v) => v.value === rolesName)
            setValue('newRoles', findRoles || findRole)
        }

        if (data?.roles === Eroles.REGIONAL_MANAGER) {
            const region = await bySearchRegion(location)
            const dFilter = region.filter((v) => {
                const parse = JSON.parse(v.value) as Region
                return parse.name === location
            })
            setValue('newRegion', dFilter[0])

            setLocationDefault(dFilter)
        }
        if (rolesNeedBranch(`${data?.roles}`)) {
            const branch = await bySearchBranch(location)
            const dFilter = branch.filter((v) => {
                const parse = JSON.parse(v.value) as Branch
                return parse.name === location
            })
            setValue('newBranch', dFilter[0])
            setLocationBranchDefault(dFilter)
        }

        const findTeam = TYPE_TEAM.find((i) => i.value === teamName)
        setValue('newTeam', findTeam)

        setIsLoading(false)
    }

    React.useEffect(() => {
        if (data) {
            reset(data)
            setDefault()
            setPreview(data.imageUrl)
        }
    }, [data])

    React.useEffect(() => {
        if (watch('newTeam.value')) {
            const team = getValues('newTeam.value')
            if (team === entity.Team.FOOD_SERVICE) setRoles(ROLES_FOOD_SERVICE)
            else if (team === entity.Team.RETAIL) setRoles(ROLES_RETAIL)
            else setRoles(ROLES_ADMIN)
        } else {
            setRoles(ROLES_ADMIN)
        }
    }, [watch('newTeam'), roles])

    const onSubmit: SubmitHandler<ReqTypes> = async (data) => {
        let team = 0
        let location: Location | null = null
        const category: ECategory[] = []

        if (getValues('newRegion.value')) {
            const region = JSON.parse(getValues('newRegion.value')) as Region
            location = {
                id: region.id,
                name: region.name,
                type: 1,
            }
        }

        if (getValues('newBranch.value')) {
            const branch = JSON.parse(getValues('newBranch.value')) as Branch
            location = {
                id: branch.id,
                name: branch.name,
                type: 2,
            }
        }

        if (getValues('newCategory')) {
            const categorys = getValues('newCategory')
            categorys?.forEach((i) => {
                const data = JSON.parse(i.value) as ECategory
                category.push(data)
            })
        }

        if (getValues('newTeam.value')) {
            team = Number(getValues('newTeam.value'))
        }

        // const rolesNeedLocation = [
        //     Eroles.BRANCH_FINANCE_ADMIN,
        //     Eroles.BRANCH_ADMIN,
        //     Eroles.AREA_MANAGER,
        //     Eroles.REGIONAL_MANAGER,
        //     Eroles.BRANCH_SALES_ADMIN,
        //     Eroles.WAREHOUSE_ADMIN,
        //     Eroles.BRANCH_WAREHOUSE_ADMIN,
        //     Eroles.SALES,
        //     Eroles.COURIER,
        // ]

        // if (rolesNeedLocation.includes(data.roles)) {
        //     location = data.location
        // }

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

        await createUpdate.mutateAsync(ReqData)
        setIsOpenEdit(false)
    }

    const rolesNeedBranch = (roles: string) => {
        return (
            roles === `${Eroles.BRANCH_ADMIN}` ||
            roles === `${Eroles.AREA_MANAGER}` ||
            roles === `${Eroles.SALES}` ||
            roles === `${Eroles.BRANCH_FINANCE_ADMIN}` ||
            roles === `${Eroles.BRANCH_SALES_ADMIN}` ||
            roles === `${Eroles.BRANCH_WAREHOUSE_ADMIN}`
        )
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setIsOpenEdit(false)} size={'5xl'} title="Detail Akun">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <>
                    <VisuallyHidden>{JSON.stringify(watch('newRoles'))}</VisuallyHidden>

                    <form onSubmit={handleSubmit(onSubmit)}>
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
                                    defaultValue={getValues('newTeam')}
                                    control={control}
                                    label={'newTeam'}
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
                                        defaultValue={locationDefault}
                                        loadOptions={bySearchRegion}
                                        label="newRegion"
                                        title={'Region'}
                                        placeholder="Pilih Region"
                                        control={control}
                                        errors={errors.newRegion?.value?.message}
                                        defaultOptions={false}
                                    />
                                ) : rolesNeedBranch(watch('newRoles.value')) ? (
                                    <FormSelects
                                        async
                                        defaultValue={locationDefaultBranch}
                                        loadOptions={bySearchBranch}
                                        label="newBranch"
                                        title={'Cabang'}
                                        placeholder="Pilih Cabang"
                                        control={control}
                                        errors={errors.newBranch?.value?.message}
                                        defaultOptions={false}
                                    />
                                ) : null}
                            </Box>
                        </SimpleGrid>

                        <ButtonForm label={'Simpan'} isLoading={createUpdate.isLoading} onClose={() => setIsOpenEdit(false)} />
                    </form>
                </>
            )}
        </Modals>
    )
}

export default UserDetailPages

import React from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, LoadingForm, Modals, PText } from 'ui'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '~/utils/shared'
import { Image } from '@chakra-ui/image'

import { disclousureStore } from '~/store'
import { employeeService, store, usePickImage } from 'hooks'
import { CreateEmployee, Employee, Eroles } from 'apis'

const CourierDetailPages: React.FC<{ id: string }> = ({ id }) => {
    const admin = store.useStore((i) => i.admin)
    const setEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const { selectedFile, setPreview } = usePickImage()
    const { create } = employeeService.useEmployee()
    const { data, isLoading, error } = employeeService.useGetByIdEmployee(id)

    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<Employee>()

    React.useEffect(() => {
        if (data) {
            reset(data)
            setPreview(data.imageUrl)
        }
    }, [isLoading])

    const onSubmit: SubmitHandler<Employee> = async (data) => {
        const ReqData: CreateEmployee = {
            id: data.id,
            name: data.name,
            email: data.email,
            phone: data.phone,
            location: {
                id: admin?.location?.id ?? '',
                name: admin?.location?.name ?? '',
                type: admin?.location?.type ?? 2,
            },
            image_: selectedFile,
            team: 0,
            roles: Eroles.COURIER,
        }
        await create.mutateAsync(ReqData)
        setEdit(false)
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={() => setEdit(false)} size={'4xl'} title="Detail Kurir">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <SimpleGrid columns={2} columnGap={5} mb={3}>
                            <Box experimental_spaceY={'10px'}>
                                <Image src={data?.imageUrl} w={'150px'} h={'150px'} rounded={'lg'} />
                                <FormControls
                                    readOnly
                                    label="id"
                                    register={register}
                                    title={'ID'}
                                    errors={errors.name?.message}
                                    pattern={{
                                        value: RegExSpescialChar,
                                        message: 'ID hanya boleh huruf dan angka',
                                    }}
                                    required={'ID User tidak boleh kosong'}
                                />
                            </Box>

                            <Box experimental_spaceY={'10px'}>
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
                            </Box>
                        </SimpleGrid>
                        <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setEdit(false)} />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default CourierDetailPages

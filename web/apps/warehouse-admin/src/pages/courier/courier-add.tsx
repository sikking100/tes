import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, Modals } from 'ui'
import { RegExEmail, RegExPhoneNumber, RegExSpescialChar } from '~/utils/shared'
import { Eroles, type CreateEmployee } from 'apis'
import { store, usePickImage, employeeService } from 'hooks'
import { disclousureStore } from '~/store'

type ReqTypes = CreateEmployee

const CourierAddPages = () => {
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const admin = store.useStore((i) => i.admin)
    const { selectedFile } = usePickImage()
    const { create } = employeeService.useEmployee()

    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<ReqTypes>()

    const onSubmit: SubmitHandler<ReqTypes> = async (data) => {
        if (!admin) return
        const ReqData: CreateEmployee = {
            id: data.id,
            name: data.name,
            email: data.email,
            phone: data.phone,
            location: admin.location,
            image_: selectedFile,
            team: 0,
            roles: Eroles.COURIER,
        }
        // if (ReqData.phone.startsWith('0')) ReqData.phone = ReqData.phone.replace('0', '+62')

        await create.mutateAsync(ReqData)
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'2xl'} title="Tambah Kurir">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={3}>
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

                <ButtonForm label={'Simpan'} isLoading={create.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default CourierAddPages

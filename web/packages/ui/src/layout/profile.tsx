import { FC, useEffect } from 'react'
import { Box, SimpleGrid } from '@chakra-ui/layout'
import { useForm } from 'react-hook-form'

import { Buttons, FormControls, ImagePick, LoadingForm, PText, Root } from '..'
import { employeeService, usePickImage } from 'hooks'
import type { Employee } from 'apis'
import { appName, ListSidebarProps } from '../types'

interface Props {
    items: ListSidebarProps[]
    appName: appName
}

interface TEmployee extends Employee {
    image_?: File
}

const Profile: FC<Props> = (props) => {
    const { update } = employeeService.useEmployee()
    const { data, error, isLoading } = employeeService.useGetByIdEmployee(
        String(localStorage.getItem('admin-id'))
    )
    const { preview, onSelectFile, selectedFile, setPreview, setSelectedFile } =
        usePickImage()
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
        setValue,
    } = useForm<TEmployee>({})

    useEffect(() => {
        if (data) {
            reset(data)
            setPreview(String(data.imageUrl))
        }
    }, [data])

    useEffect(() => {
        if (selectedFile) setValue('image_', selectedFile)
    }, [selectedFile])

    const onSubmit = async (data: TEmployee) => {
        await update.mutateAsync({
            ...data,
            image_: selectedFile,
        })
    }

    return (
        <Root
            appName={props.appName}
            items={props.items}
            backUrl={`/`}
            activeNum={1}
        >
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <form onSubmit={handleSubmit(onSubmit)}>
                    <SimpleGrid columns={2} columnGap={5} rowGap={5}>
                        <Box experimental_spaceY={4}>
                            <FormControls
                                label="name"
                                title="Nama"
                                register={register}
                                errors={errors.name?.message}
                                required={'Nama tidak boleh kosong'}
                            />
                            <FormControls
                                label="phone"
                                title="Nomor HP"
                                register={register}
                                errors={errors.phone?.message}
                                required={'Nomor HP tidak boleh kosong'}
                            />

                            <FormControls
                                label="email"
                                title="Email"
                                register={register}
                                pattern={{
                                    value: /\S+@\S+\.\S+/,
                                    message: 'Masukkan email yang valid',
                                }}
                                errors={errors.email?.message}
                                required={'Email tidak boleh kosong'}
                            />
                            <Buttons
                                label="Update"
                                isLoading={update.isLoading}
                                type={'submit'}
                                mt={'20px !important'}
                                w={'150px'}
                            />
                        </Box>
                        <Box w="fit-content">
                            <ImagePick
                                title="Foto"
                                w={'250px'}
                                h={'280px'}
                                idImage="profile"
                                imageUrl={preview as string}
                                onChangeInput={(e) => onSelectFile(e.target)}
                            />
                        </Box>
                    </SimpleGrid>
                </form>
            )}
        </Root>
    )
}

export default Profile

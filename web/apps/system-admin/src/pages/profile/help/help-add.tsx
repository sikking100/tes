import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControls, Modals } from 'ui'
import { helpService, store } from 'hooks'
import type { CreateHelp } from 'apis'
import { disclousureStore } from '~/store'

const HelpAddPages = () => {
    const admin = store.useStore((v) => v.admin)
    const { createHelp } = helpService.useHelp()
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)
    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<CreateHelp>()

    const onSubmit: SubmitHandler<CreateHelp> = async (data) => {
        await createHelp.mutateAsync({
            ...data,
            creator: {
                id: `${admin?.id}`,
                description: '-',
                imageUrl: `${admin?.imageUrl}`,
                name: `${admin?.name}`,
                roles: Number(admin?.roles),
            },
        })
        setOpenAdd(false)
    }

    return (
        <Modals isOpen={isAdd} setOpen={() => setOpenAdd(false)} size={'3xl'} title="Tambah Bantuan">
            <form onSubmit={handleSubmit(onSubmit)}>
                <Box experimental_spaceY={3}>
                    <FormControls
                        label="topic"
                        register={register}
                        title={'Topik'}
                        errors={errors.topic?.message}
                        required={'Topik tidak boleh kosong'}
                    />

                    <FormControls
                        label="question"
                        register={register}
                        title={'Pertanyaan'}
                        errors={errors.question?.message}
                        required={'Pertanyaan tidak boleh kosong'}
                    />

                    <FormControls
                        label="answer"
                        register={register}
                        title={'Jawaban'}
                        errors={errors.answer?.message}
                        required={'Jawaban tidak boleh kosong'}
                    />
                </Box>
                <ButtonForm label={'Simpan'} isLoading={createHelp.isLoading} onClose={() => setOpenAdd(false)} />
            </form>
        </Modals>
    )
}

export default HelpAddPages

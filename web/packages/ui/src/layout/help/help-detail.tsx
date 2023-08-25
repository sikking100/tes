import React from 'react'
import { Box } from '@chakra-ui/layout'
import { SubmitHandler, useForm } from 'react-hook-form'
import { useNavigate, useParams } from 'react-router-dom'
import {
    ButtonForm,
    FormControls,
    FormControlsTextArea,
    LoadingForm,
    Modals,
    PText,
} from '../..'
import { helpService } from 'hooks'
import type { Help } from 'apis'

const HelpDetailPages = () => {
    const params = useParams()
    const navigate = useNavigate()
    const { updateHelp } = helpService.useHelp()
    const { data, error, isLoading } = helpService.useGetHelpById(
        String(params.id)
    )
    const {
        handleSubmit,
        register,
        formState: { errors },
        reset,
    } = useForm<Help>()

    React.useEffect(() => {
        if (data) reset(data)
    }, [data])

    const onSubmit: SubmitHandler<Help> = async (data) => {
        await updateHelp.mutateAsync(data)
        navigate(-1)
    }

    return (
        <Modals
            isOpen={true}
            setOpen={() => navigate(`/help`)}
            size={'3xl'}
            title="Detail Bantuan"
        >
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <form onSubmit={handleSubmit(onSubmit)}>
                    <Box experimental_spaceY={3}>
                        <FormControls
                            readOnly
                            label="topic"
                            register={register}
                            title={'Topik'}
                            errors={errors.topic?.message}
                            required={'Topik tidak boleh kosong'}
                        />

                        <FormControls
                            readOnly
                            label="question"
                            register={register}
                            title={'Pertanyaan'}
                            errors={errors.question?.message}
                            required={'Pertanyaan tidak boleh kosong'}
                        />

                        <FormControlsTextArea
                            readOnly
                            label="answer"
                            register={register}
                            title={'Jawaban'}
                            errors={errors.answer?.message}
                            required={'Jawaban tidak boleh kosong'}
                        />
                    </Box>
                    <ButtonForm
                        label={'Simpan'}
                        isLoading={updateHelp.isLoading}
                        onClose={() => navigate(`/help`)}
                    />
                </form>
            )}
        </Modals>
    )
}

export default HelpDetailPages

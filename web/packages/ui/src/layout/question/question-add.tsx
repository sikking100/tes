import React from 'react'
import { SubmitHandler, useForm } from 'react-hook-form'
import { useNavigate, useParams } from 'react-router-dom'
import {
    ButtonForm,
    FormControlsTextArea,
    LoadingForm,
    Modals,
    PText,
} from '../..'
import { helpService, store } from 'hooks'
import type { CreateQuestion, CreatorHelp, Help } from 'apis'
import { Avatar, Box, HStack, Text } from '@chakra-ui/react'

export const QuestionAddPages: React.FC<{
    cb: () => void
    isOpen: boolean
}> = ({ cb, isOpen }) => {
    const admin = store.useStore((i) => i.admin)

    const { createQuestion } = helpService.useHelp()
    const {
        handleSubmit,
        register,
        formState: { errors },
    } = useForm<CreateQuestion>()

    const onClose = () => cb()

    const onCreate = async (req: CreateQuestion) => {
        const ReqData: CreateQuestion = {
            ...req,
            creator: {
                id: `${admin?.id}`,
                description: 'desc',
                imageUrl: `${admin?.imageUrl}`,
                name: `${admin?.name}`,
                roles: Number(admin?.roles),
            },
        }

        await createQuestion.mutateAsync(ReqData)
        onClose()
    }

    return (
        <Modals isOpen={isOpen} setOpen={onClose} title="Ajukan Pertanyaan">
            <form onSubmit={handleSubmit(onCreate)}>
                <FormControlsTextArea
                    label="question"
                    title={'Pertanyaan'}
                    register={register}
                    errors={errors.question?.message}
                    required={'Pertanyaan tidak boleh kosong'}
                />

                <ButtonForm
                    label={'Ajukan'}
                    isLoading={createQuestion.isLoading}
                    onClose={onClose}
                />
            </form>
        </Modals>
    )
}

export const QuestionDetailPages = () => {
    const navigate = useNavigate()
    const params = useParams()
    const createdBy = React.useRef<CreatorHelp | null>(null)
    const { data, error, isLoading } = helpService.useGetHelpById(
        String(params.id)
    )
    const { updateQuestion } = helpService.useHelp()
    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
        getValues,
    } = useForm<Help>()

    React.useEffect(() => {
        if (data) {
            reset(data)
            createdBy.current = data.creator
        }
    }, [data])

    const onClose = () => navigate(-1)

    const onSubmit: SubmitHandler<Help> = async (data) => {
        await updateQuestion.mutateAsync(data)
        onClose()
    }

    return (
        <Modals isOpen={true} setOpen={onClose} title="Detail Pertanyaan">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <HStack>
                        <Avatar
                            src={createdBy.current?.imageUrl}
                            name={createdBy.current?.name}
                        />
                        <Box experimental_spaceY={2}>
                            <Text>{createdBy.current?.name}</Text>
                            <Text>{createdBy.current?.roles}</Text>
                        </Box>
                    </HStack>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <FormControlsTextArea
                            label="question"
                            title={'Pertanyaan'}
                            register={register}
                            errors={errors.question?.message}
                            required={'Pertanyaan tidak boleh kosong'}
                        />

                        <FormControlsTextArea
                            label="answer"
                            title={'Jawaban'}
                            register={register}
                            errors={errors.question?.message}
                            required={'Jawaban tidak boleh kosong'}
                        />

                        <ButtonForm
                            label={'Jawab'}
                            isLoading={updateQuestion.isLoading}
                            onClose={onClose}
                        />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

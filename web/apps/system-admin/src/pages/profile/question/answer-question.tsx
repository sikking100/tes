import React from 'react'
import { SubmitHandler, useForm } from 'react-hook-form'
import { ButtonForm, FormControlsTextArea, LoadingForm, Modals, PText, entity } from 'ui'
import { Avatar, HStack, Text, Box } from '@chakra-ui/react'
import { CreatorHelp, Help } from 'apis'
import { helpService } from 'hooks'
import { disclousureStore } from '~/store'

export const AnswerQuestionPages: React.FC<{ id: string }> = ({ id }) => {
    const createdBy = React.useRef<CreatorHelp | null>(null)
    const { data, error, isLoading } = helpService.useGetHelpById(id)
    const { updateQuestion } = helpService.useHelp()
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    const {
        handleSubmit,
        register,
        reset,
        formState: { errors },
    } = useForm<Help>()

    React.useEffect(() => {
        if (data) {
            reset(data)
        }
    }, [isLoading])

    const onClose = () => setIsOpenEdit(false)

    const onSubmit: SubmitHandler<Help> = async (data) => {
        await updateQuestion.mutateAsync({
            ...data,
        })
        onClose()
    }

    return (
        <Modals isOpen={isOpenEdit} setOpen={onClose} title="Detail Pertanyaan" size="4xl">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <HStack>
                        <Avatar src={createdBy.current?.imageUrl} name={createdBy.current?.name} size="xl" />
                        <Box experimental_spaceY={1} fontWeight={600} fontSize={'xl'}>
                            <Text>{createdBy.current?.name}</Text>
                            <Text fontSize={'md'}>{entity.roles(Number(data?.creator.roles))}</Text>
                        </Box>
                    </HStack>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Box experimental_spaceY={3} mt={3}>
                            <FormControlsTextArea
                                label="question"
                                title={'Pertanyaan'}
                                register={register}
                                errors={errors.question?.message}
                                required={'Pertanyaan tidak boleh kosong'}
                                isDisabled={true}
                            />

                            <FormControlsTextArea
                                label="answer"
                                title={'Jawaban'}
                                register={register}
                                errors={errors.question?.message}
                                required={'Jawaban tidak boleh kosong'}
                            />
                        </Box>

                        <ButtonForm label={'Jawab'} isLoading={updateQuestion.isLoading} onClose={onClose} />
                    </form>
                </React.Fragment>
            )}
        </Modals>
    )
}

export default AnswerQuestionPages

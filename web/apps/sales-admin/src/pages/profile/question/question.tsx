import React from 'react'
import { Flex, TabPanel, Box, Text, Table, Tr, Td, Spinner } from '@chakra-ui/react'
import { helpService, store } from 'hooks'
import { Buttons, PText, Root, Shared, TabsComponent, Types } from 'ui'
import { Help } from 'apis'
import LayoutQuestionDetailQuestion from './detail'
import { dataListProfile } from '../../../navigation'
import { disclousureStore } from '~/store'
import QuestionAddPages from './question-add'

const Wrap: React.FC<{ children: React.ReactNode; appName: Types.appName }> = (props) => (
    <Root items={dataListProfile} backUrl={'/'} activeNum={2} appName={props.appName}>
        {props.children}
    </Root>
)

const QuestionComplete: React.FC<{ isAnswer: boolean }> = ({ isAnswer }) => {
    const [id, setId] = React.useState<Help>()
    const { data, error, isLoading } = helpService.useGetHelp({
        isAnswered: isAnswer,
        userId: store.useStore().admin?.id ?? '',
    })
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)
    const isAdd = disclousureStore((v) => v.isAdd)

    return (
        <Flex direction={'column'} experimental_spaceY={3} overflow={'auto'} pb={2} mt={2}>
            {isAdd && <QuestionAddPages />}
            {isOpenEdit && id && <LayoutQuestionDetailQuestion data={id} />}
            {error && <PText label={error} />}
            {isLoading && <Spinner />}
            {!isLoading && data && (
                <>
                    {data.items.map((i) => (
                        <Box
                            key={i.id}
                            rounded={'lg'}
                            bg={'white'}
                            py={4}
                            pr={5}
                            pl={3}
                            _hover={{
                                border: '0.5px solid #EE6C6B',
                                cursor: 'pointer',
                            }}
                            onClick={() => {
                                setIsOpenEdit(true)
                                setId(i)
                            }}
                        >
                            <Text pl={'20px'}>{Shared.FormatDateToString(i.createdAt)}</Text>
                            <Table>
                                <Tr>
                                    <Td w={'20px'}>Pertanyaan</Td>
                                    <Td w={'5px'}>:</Td>
                                    <Td>{i.question}</Td>
                                </Tr>
                                <Tr>
                                    <Td>Jawaban</Td>
                                    <Td>:</Td>
                                    <Td>{i.answer}</Td>
                                </Tr>
                            </Table>
                        </Box>
                    ))}
                </>
            )}
        </Flex>
    )
}

const QuestionPages = () => {
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const isAdd = disclousureStore((v) => v.isAdd)

    return (
        <Wrap appName={'Branch'}>
            {isAdd && <QuestionAddPages />}
            <Buttons label="Ajukan Pertanyaan" mb={1} onClick={() => setOpenAdd(true)} />

            <TabsComponent TabList={['Belum Dijawab', 'Sudah Dijawab']} defaultIndex={0} link={'/question'}>
                <TabPanel px={0}>
                    <QuestionComplete isAnswer={false} />
                </TabPanel>
                <TabPanel px={0}>
                    <QuestionComplete isAnswer={true} />
                </TabPanel>
            </TabsComponent>
        </Wrap>
    )
}

export default QuestionPages

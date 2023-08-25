import React from 'react'
import { Flex, TabPanel, Box, Text, Table, Tr, Td } from '@chakra-ui/react'
import { helpService } from 'hooks'
import { Root, Shared, TabsComponent } from 'ui'
import { dataListProfile } from '~/navigation'
import { disclousureStore } from '~/store'
import AnswerQuestionPages from './answer-question'

const Wrap: React.FC<{ children: React.ReactNode }> = (props) => (
    <Root items={dataListProfile} backUrl={'/'} activeNum={2} appName={'System'}>
        {props.children}
    </Root>
)

const QuestionComplete: React.FC<{ isAnswer: boolean }> = ({ isAnswer }) => {
    const { data, error, isLoading } = helpService.useGetHelp({
        isAnswered: isAnswer,
        isHelp: false,
    })
    const [id, setId] = React.useState('')
    const setIsOpenEdit = disclousureStore((v) => v.setIsOpenEdit)
    const isOpenEdit = disclousureStore((v) => v.isOpenEdit)

    if (error) return <Text>{error}</Text>
    if (isLoading) return <Text>Loading...</Text>

    return (
        <React.Fragment>
            {isOpenEdit && id && <AnswerQuestionPages id={id} />}
            <Flex direction={'column'} experimental_spaceY={3} overflow={'auto'} pb={2}>
                {data.items.map((i) => (
                    <Box
                        key={i.id}
                        onClick={() => {
                            setIsOpenEdit(true)
                            setId(i.id)
                        }}
                    >
                        <Box rounded={'lg'} bg={'white'} py={4} pr={5} pl={3}>
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
                    </Box>
                ))}
            </Flex>
        </React.Fragment>
    )
}

const QuestionPages = () => {
    const TabList = ['Belum Dijawab', 'Sudah Dijawab']
    return (
        <Wrap>
            <TabsComponent TabList={TabList} defaultIndex={0} link={'/question'}>
                <TabPanel px={0} pt={7}>
                    <QuestionComplete isAnswer={false} />
                </TabPanel>
                <TabPanel px={0} pt={7}>
                    <QuestionComplete isAnswer={true} />
                </TabPanel>
            </TabsComponent>
        </Wrap>
    )
}

export default QuestionPages

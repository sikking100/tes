import React from 'react'
import { Flex, TabPanel, Box, Text, Table, Tr, Td } from '@chakra-ui/react'
import { Link, useNavigate } from 'react-router-dom'
import { helpService } from 'hooks'
import { Buttons, Root, Shared, TabsComponent, Types } from '../..'
import { dataListProfile } from '../help/help'

const Wrap: React.FC<{ children: React.ReactNode; appName: Types.appName }> = (
    props
) => (
    <Root
        items={dataListProfile}
        backUrl={`/`}
        activeNum={2}
        appName={props.appName}
    >
        {props.children}
    </Root>
)

const QuestionComplete: React.FC<{ isAnswer: boolean }> = ({ isAnswer }) => {
    const { data, error, isLoading } = helpService.useGetHelp({
        isAnswered: isAnswer,
        userId: String(localStorage.getItem('admin-id')),
    })

    if (error) return <Text>{error}</Text>
    if (isLoading) return <Text>Loading...</Text>

    return (
        <Flex
            direction={'column'}
            experimental_spaceY={3}
            overflow={'auto'}
            pb={2}
            mt={2}
        >
            {data.items.map((i) => (
                <Link key={i.id} to={`/question/${i.id}`}>
                    <Box
                        rounded={'lg'}
                        bg={'white'}
                        py={4}
                        pr={5}
                        pl={3}
                        _hover={{
                            border: '0.5px solid #EE6C6B',
                            cursor: 'pointer',
                        }}
                    >
                        <Text pl={'20px'}>
                            {Shared.FormatDateToString(i.createdAt)}
                        </Text>
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
                </Link>
            ))}
        </Flex>
    )
}

const QuestionPages: React.FC<{ appName: Types.appName }> = ({ appName }) => {
    const navigate = useNavigate()
    const listNavigation = ['Belum Dijawab', 'Sudah Dijawab']
    return (
        <Wrap appName={appName}>
            <Buttons
                label="Ajukan Pertanyaan"
                mb={1}
                onClick={() => navigate('/question/add', { replace: true })}
            />

            <TabsComponent
                TabList={listNavigation}
                defaultIndex={0}
                link={'/business'}
            >
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

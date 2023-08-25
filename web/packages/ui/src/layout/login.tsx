import '../theme/global.css'
import React, { useState } from 'react'
import { loginService, SetFcm } from 'hooks'
import { Eroles, ReqLogin } from 'apis'

import {
    Box,
    Heading,
    Input,
    InputGroup,
    InputLeftAddon,
    Text,
    VStack,
    HStack,
    PinInput,
    PinInputField,
    SimpleGrid,
    Center,
    Image,
    Modal,
    Spinner,
    ModalBody,
    ModalContent,
    ModalOverlay,
} from '@chakra-ui/react'
import { ChevronLeftIcon } from '@chakra-ui/icons'
import { Buttons } from '../button'
import DfImage from '../../assets/logo-white-df.webp'
import DfDevliveryImg from '../../assets/df-delivery.webp'
import { appName } from '../types'
import { useNavigate } from 'react-router-dom'

interface ISendPhoneNumber {
    appName: appName
    phoneNumber: string
    onChange?: React.ChangeEventHandler<HTMLInputElement> | undefined
    buttonOnClick?: React.MouseEventHandler<HTMLButtonElement> | undefined
    isLoading: boolean
    Login: (v: string) => void
}

interface ISendOTP {
    roles: appName
    isBack: (val: boolean) => void
}

interface ILogin {
    roles: appName
}

const LoadingLogin: React.FC<{ isOpen: boolean }> = ({ isOpen }) => (
    <Modal isCentered isOpen={isOpen} onClose={() => undefined} size="sm">
        <ModalOverlay />
        <ModalContent>
            <ModalBody>
                <Center bg={'white'} h={'150px'}>
                    <Spinner
                        thickness="8px"
                        speed="1s"
                        emptyColor="gray.200"
                        color="red.200"
                        width={'100px'}
                        height={'100px'}
                    />
                </Center>
            </ModalBody>
        </ModalContent>
    </Modal>
)

const Login: React.FC<ILogin> = (props) => {
    const { login } = loginService.useLogin()
    const [phoneNumber, setPhoneNumber] = useState<string>('')
    const [isSendOtp, setIsSendOtp] = React.useState(false)

    React.useEffect(() => {
        const SetTokenFcm = async () => {
            const setFcm = await SetFcm()
            localStorage.setItem('fcm', setFcm)
        }
        SetTokenFcm()
    }, [])

    const onChange = (e: string) => {
        // const numbers = /^(0|[0-9]\d*)$/
        // if (!e.match(numbers)) {
        //     if (phoneNumber.length === 1) setPhoneNumber('')
        //     return
        // }
        setPhoneNumber(e)
    }

    const onCheckRoles = (): number => {
        switch (props.roles) {
            case 'System':
                // return Eroles.SYSTEM_ADMIN
                return 2
            case 'Finance':
                // return Eroles.FINANCE_ADMIN
                return 3
            case 'Sales':
                // return Eroles.SALES_ADMIN
                return 4
            case 'Branch':
                // return Eroles.BRANCH_ADMIN
                return 5
            case 'Warehouse':
                // return Eroles.BRANCH_WAREHOUSE_ADMIN
                return 6
            default:
                return 100
        }
    }

    const handleSendPhoneNumber = async () => {
        const ReData: ReqLogin = {
            phone: '+62' + phoneNumber,
            app: onCheckRoles(),
            fcmToken: '',
        }
        await login.mutateAsync(ReData).then(() => setIsSendOtp(true))
    }

    return (
        <Box bg={'red.100'}>
            <Image
                src={DfImage}
                pos={'absolute'}
                w={'200px'}
                m={10}
                alt="image-login"
            />
            <SimpleGrid h={'100vh'} columns={2} w={'full'}>
                <Center>
                    <VStack>
                        <Image
                            src={DfDevliveryImg}
                            w={'350px'}
                            h={'300px'}
                            loading="lazy"
                            alt="image-login"
                        />
                        <div style={{ color: '#FFF' }}>
                            <Text>Bringing The World`s Best</Text>
                            <Text>Bakery Ingredients To You</Text>
                        </div>
                    </VStack>
                </Center>

                <Center>
                    {!isSendOtp ? (
                        <SendPhoneNumber
                            appName={props.roles}
                            isLoading={login.isLoading}
                            phoneNumber={phoneNumber}
                            buttonOnClick={handleSendPhoneNumber}
                            Login={handleSendPhoneNumber}
                            onChange={(e) => onChange(e.target.value)}
                        />
                    ) : (
                        <SendOTP roles={props.roles} isBack={setIsSendOtp} />
                    )}
                </Center>
            </SimpleGrid>
            <Text
                textAlign={'center'}
                pos={'fixed'}
                bottom={5}
                left={0}
                width={'100%'}
                color={'white'}
            >
                &copy; {new Date().getFullYear()} PT. Dairyfood Internusa
            </Text>
        </Box>
    )
}

const SendPhoneNumber: React.FC<ISendPhoneNumber> = (props) => {
    const EnterLoginPhoneNumber = (e?: React.KeyboardEvent<HTMLDivElement>) => {
        if (e?.key === 'Enter') {
            props.Login('+62' + props.phoneNumber)
        }
    }

    return (
        <SimpleGrid
            columns={1}
            bg={'#FFF'}
            rounded={'xl'}
            px={6}
            pt={6}
            w={600}
            h={400}
        >
            <Heading fontSize={28} fontWeight={600}>
                Login {props.appName} Administrator
            </Heading>
            <Box w={'full'} experimental_spaceY={7} pt={5}>
                <Box>
                    <Text fontWeight={500} mb={2}>
                        Nomor Handphone
                    </Text>
                    <InputGroup>
                        <InputLeftAddon>+62</InputLeftAddon>
                        <Input
                            role={'textbox'}
                            placeholder="Ketik Nomor Handphone"
                            value={props.phoneNumber}
                            onChange={props.onChange}
                            onKeyPress={EnterLoginPhoneNumber}
                        />
                    </InputGroup>
                    <Text pt={4} fontSize={'sm'}>
                        6 digit OTP akan dikirim ke HP Anda untuk verifikasi
                    </Text>
                </Box>
            </Box>
            <Buttons
                label="Login"
                color={'black'}
                isLoading={props.isLoading}
                bg="yellow.100"
                // isDisabled={props.phoneNumber.length < 8 ? true : false}
                onClick={props.buttonOnClick}
            />
        </SimpleGrid>
    )
}

const SendOTP: React.FC<ISendOTP> = (props) => {
    const { loginVerify } = loginService.useLogin()
    const navigate = useNavigate()
    const [loading, setLoading] = React.useState(false)
    const [codeOtp, setCodeOtp] = useState<string>('')

    React.useEffect(() => {
        if (codeOtp.length === 6) onLogin()
    }, [codeOtp])

    const onLogin = async () => {
        setLoading(true)
        loginVerify
            .mutateAsync({ otp: codeOtp, id: '' })
            .then(() => {
                navigate('/', { replace: true })
            })
            .finally(() => {
                setLoading(false)
            })
    }

    const EnterLoginVerify = async (
        e?: React.KeyboardEvent<HTMLDivElement>
    ) => {
        if (e?.key === 'Enter') onLogin()
    }

    return (
        <VStack
            align={'start'}
            bg={'white'}
            rounded={'xl'}
            p={'30px'}
            w={500}
            h={400}
            spacing={'60px'}
        >
            <LoadingLogin isOpen={loading} />
            <HStack>
                <ChevronLeftIcon
                    fontSize={28}
                    _hover={{ cursor: 'pointer' }}
                    onClick={() => props.isBack(false)}
                />
                <Heading fontSize={28} fontWeight={600}>
                    Verifikasi
                </Heading>
            </HStack>
            <VStack align={'flex-start'}>
                <Text mb="8px">Masukkan Kode OTP</Text>
                <HStack spacing={3}>
                    <PinInput
                        otp
                        type="alphanumeric"
                        size="lg"
                        value={codeOtp}
                        onChange={(e) => setCodeOtp(e)}
                    >
                        {[1, 2, 3, 4, 5, 6].map((it, id) => (
                            <PinInputField
                                key={id}
                                _focus={{ borderColor: 'red.100' }}
                                onKeyPress={EnterLoginVerify}
                            />
                        ))}
                    </PinInput>
                </HStack>
                <VStack align={'center'} spacing={0} pt={1}>
                    <Text>Anda akan menerima sms kode OTP</Text>
                    <Text>pada nomor yang telah dimasukkan</Text>
                </VStack>
            </VStack>
            <Buttons
                label="Verifikasi"
                color={'black'}
                bg="yellow.100"
                isDisabled={codeOtp.length < 6 ? true : false}
                onClick={onLogin}
            />
        </VStack>
    )
}

export default Login

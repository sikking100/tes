import React from 'react'
import { Step, Steps, useSteps } from 'chakra-ui-steps'
import { Flex, HStack } from '@chakra-ui/layout'
import { Button, ButtonProps } from '@chakra-ui/button'
import { Icons } from 'ui'
import { useStoreSteps } from '~/store'

interface IConntet {
    label: string
    content: React.ReactNode
    btnNextDisable?: boolean
    btnPrevDisable?: boolean
}

interface StepsTimeLineProps {
    content: IConntet[]
    btnNextStyle?: ButtonProps
    btnPrevStyle?: ButtonProps
    idx?: number
}

const StepsTimeLine: React.FC<StepsTimeLineProps> = ({ content, btnNextStyle, btnPrevStyle, idx }) => {
    const disableNext = useStoreSteps((i) => i.disableNext)
    const disablePrev = useStoreSteps((i) => i.disablePrev)

    const { nextStep, prevStep, setStep, reset, activeStep } = useSteps({
        initialStep: 0,
    })

    return (
        <div>
            <Flex flexDir="column" width="100%">
                <Steps activeStep={activeStep}>
                    {content.map(({ label, content, btnNextDisable, btnPrevDisable }, ln) => {
                        if (activeStep === ln) {
                            return (
                                <Step label={label} key={label} isCompletedStep={activeStep === ln}>
                                    <React.Fragment>{content}</React.Fragment>
                                </Step>
                            )
                        }

                        return (
                            <Step label={label} key={label}>
                                <React.Fragment>{content}</React.Fragment>
                            </Step>
                        )
                    })}
                </Steps>
                <HStack pr="20px" pb="15px" pos="absolute" bottom="0px" right={'0'} spacing={0}>
                    <Button isDisabled={activeStep === 0} mr={4} onClick={prevStep} color={'white'} bg="red.100" {...btnPrevStyle}>
                        <Icons.ArrowLeftIcons />
                    </Button>
                    <Button onClick={nextStep} color={'white'} bg="red.100" isDisabled={disableNext}>
                        <Icons.ArrowRightIcons />
                    </Button>
                </HStack>
            </Flex>
        </div>
    )
}

export default StepsTimeLine

import React from 'react'
import { Step, Steps, useSteps } from 'chakra-ui-steps'
import { Flex } from '@chakra-ui/layout'
import { Button, ButtonProps } from '@chakra-ui/button'
import { ArrowLeftIcons, ArrowRightIcons } from './icons'

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

const StepsTimeLine: React.FC<StepsTimeLineProps> = ({
  content,
  btnNextStyle,
  btnPrevStyle,
  idx,
}) => {
  const btnNextDisabled = btnNextStyle?.isDisabled
  const [btnNextIsDisable, setBtnNextIsDisable] = React.useState<boolean | undefined>(undefined)
  const [btnPrevIsDisable, setBtnPrevIsDisable] = React.useState<boolean | undefined>(undefined)
  const { nextStep, prevStep, setStep, reset, activeStep } = useSteps({
    initialStep: 0,
  })

  React.useEffect(() => {
    content.forEach((i) => {
      if (i.btnNextDisable !== undefined) setBtnNextIsDisable(i.btnNextDisable)
      if (i.btnPrevDisable !== undefined) setBtnPrevIsDisable(i.btnPrevDisable)
    })
  }, [content])

  return (
    <div>
      <Flex flexDir='column' width='100%'>
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
        <Flex width='100%' justify='flex-end'>
          <Button
            isDisabled={activeStep === 0}
            mr={4}
            onClick={prevStep}
            color={'white'}
            bg='red.100'
            {...btnPrevStyle}
          >
            <ArrowLeftIcons />
          </Button>
          <Button
            onClick={nextStep}
            color={'white'}
            bg='red.100'
            isDisabled={activeStep === content.length - 1}
          >
            <ArrowRightIcons />
          </Button>
        </Flex>
      </Flex>
    </div>
  )
}

export default StepsTimeLine

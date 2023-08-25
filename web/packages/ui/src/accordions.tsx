import {
  Accordion,
  AccordionButton,
  AccordionIcon,
  AccordionItem,
  AccordionPanel,
  AccordionProps,
} from '@chakra-ui/accordion'
import { Box } from '@chakra-ui/layout'
import React from 'react'

interface AccordProps extends AccordionProps {
  title: string
  children: React.ReactNode
}

const Accordions: React.FC<AccordProps> = (props) => {
  return (
    <Box>
      <Accordion defaultIndex={[0]} allowMultiple>
        <AccordionItem>
          <AccordionButton px={0} py={3}>
            <Box as='span' flex='1' textAlign='left'>
              {props.title}
            </Box>
            <AccordionIcon />
          </AccordionButton>
          <AccordionPanel px={0} pb={4}>
            {props.children}
          </AccordionPanel>
        </AccordionItem>
      </Accordion>
    </Box>
  )
}

export default Accordions

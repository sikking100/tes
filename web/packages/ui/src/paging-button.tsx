import React from 'react'
import { ChevronLeftIcon, ChevronRightIcon } from '@chakra-ui/icons'
import { Box, HStack, IconButton, Spacer, Text } from '@chakra-ui/react'

interface PagingButtonProps {
  prevPage?: React.MouseEventHandler<HTMLButtonElement>
  nextPage?: React.MouseEventHandler<HTMLButtonElement>
  disablePrev?: boolean
  disableNext: boolean
  page: number
  leftChild?: React.ReactNode
}

export const PagingButton: React.FC<PagingButtonProps> = ({
  nextPage,
  prevPage,
  page,
  disableNext,
}) => {
  return (
    <Box bottom={'10px'} right={1}>
      <HStack align={'self-end'}>
        <div />
        <Spacer />
        <HStack>
          <IconButton
            bg='red.200'
            aria-label='Call Segun'
            width={'14px'}
            disabled={page === 1}
            icon={<ChevronLeftIcon color={'white'} />}
            onClick={prevPage}
          />
          <Text> {page}</Text>
          <IconButton
            bg='red.200'
            aria-label='Call Segun'
            width={'14px'}
            disabled={disableNext}
            icon={<ChevronRightIcon color={'white'} />}
            onClick={nextPage}
          />
        </HStack>
      </HStack>
    </Box>
  )
}

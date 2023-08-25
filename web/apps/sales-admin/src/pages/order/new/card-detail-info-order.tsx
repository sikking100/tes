import React from 'react'
import { Text, Box } from '@chakra-ui/layout'

export const TextTitle: React.FC<{ title: string; val: React.ReactNode }> = ({ title, val }) => (
    <Box>
        <Text fontWeight={'semibold'}>{title}</Text>
        <Text as={'span'} fontSize={'sm'}>
            {val}
        </Text>
    </Box>
)

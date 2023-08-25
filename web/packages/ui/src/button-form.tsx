import { Box, Divider, BoxProps } from '@chakra-ui/layout'
import React from 'react'
import { Buttons } from './button'

export interface ButtonFormProps {
    label: string
    onClose: () => void
    onClick?: React.MouseEventHandler<HTMLButtonElement> | undefined
    isLoading: boolean
    isLoadingCancel?: boolean
    type?: 'button' | 'submit' | 'reset' | undefined
    labelClose?: string
    mt?: string
}

export const ButtonForm: React.FC<ButtonFormProps> = (props) => {
    return (
        <>
            <Divider mt={5} />
            <Box
                w={'50%'}
                display="flex"
                experimental_spaceX={2}
                mt={props.mt || '20px'}
                mb={'10px'}
                ml={'auto'}
                mr={0}
            >
                <Buttons
                    type={props.type || 'submit'}
                    width={'full'}
                    label={props.label}
                    isLoading={props.isLoading}
                    onClick={props.onClick}
                />
                <Buttons
                    bg="gray.100"
                    color="black"
                    label={`${props.labelClose || 'Keluar'}`}
                    width={'full'}
                    onClick={props.onClose}
                    isLoading={props.isLoadingCancel}
                />
            </Box>
        </>
    )
}

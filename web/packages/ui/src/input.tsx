import React, { FC } from 'react'
import { Button } from '@chakra-ui/button'
import { FormLabel } from '@chakra-ui/form-control'
import {
    Input,
    InputGroup,
    InputLeftElement,
    InputRightElement,
} from '@chakra-ui/input'
import { Text } from '@chakra-ui/layout'
import { IconSearch } from './icons'

import { InputSearchProps, InputsProps, InputWithButtonProps } from './types'

export const Inputs: FC<InputsProps> = (props: InputsProps) => {
    return (
        <div>
            <Text mb="3px" fontSize={'sm'}>
                {props.label}
            </Text>
            <Input
                value={props.value}
                bg="white"
                size="md"
                onChange={props.onChange}
                {...props}
            />
        </div>
    )
}

export const InputSearch: FC<InputSearchProps> = (props: InputSearchProps) => {
    return (
        <InputGroup bg={'white'} rounded={'2xl'} width={'20vw'} {...props}>
            <InputLeftElement pointerEvents="none">
                <IconSearch fontSize={18} />
            </InputLeftElement>
            <Input
                placeholder={props.placeholder}
                value={props.valueInput}
                onChange={props.onChange}
                rounded={'10px'}
                {...props}
            />
        </InputGroup>
    )
}

export const InputWithButton: FC<InputWithButtonProps> = (props) => {
    return (
        <>
            <FormLabel style={{ textTransform: 'capitalize' }} fontSize={'sm'}>
                {props.label}
            </FormLabel>
            <InputGroup size="md">
                <Input
                    pr="4.5rem"
                    value={props.valueInput}
                    onChange={props.onChange}
                />
                <InputRightElement width="4.5rem">
                    <Button h="1.75rem" size="sm" onClick={props.btnOnclick}>
                        {props.btnLabel}
                    </Button>
                </InputRightElement>
            </InputGroup>
        </>
    )
}

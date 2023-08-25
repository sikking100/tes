import {
    Avatar,
    Box,
    FormControl,
    FormErrorMessage,
    FormLabel,
    HStack,
    Input,
    InputGroup,
    InputRightElement,
    SimpleGrid,
    Skeleton,
    Text,
    Textarea,
    VStack,
} from '@chakra-ui/react'
import React from 'react'
import { NumericFormat } from 'react-number-format'
import Select, { StylesConfig } from 'react-select'
import AsyncSelect from 'react-select/async'

import { InputPropsT, SelectsPropsT } from './types'
import { Controller } from 'react-hook-form'

const customStyles: StylesConfig = {
    control: (provided: Record<string, unknown>, state: any) => ({
        ...provided,
        border: state.isFocused ? '1px solid red' : '1px solid #cccccc',
        boxShadow: state.isFocused ? 'red' : 'none',
        borderRadius: '6px',
        ':active': {
            border: '1px solid red',
        },
        '&:hover': {
            border: '1px solid red',
        },
    }),
    dropdownIndicator: (provided: any, state: any) => ({
        ...provided,
        transition: 'all .2s ease',
        transform: state.isFocused ? 'rotate(180deg)' : null,
    }),
    menuPortal: (provided) => ({ ...provided, zIndex: 9999 }),
    menu: (provided) => ({ ...provided, zIndex: 9999 }),
}

export function FormInputWithButton<T extends object>(p: InputPropsT<T>) {
    return (
        <FormControl key={p.label} isInvalid={!!p.errors}>
            <FormLabel
                htmlFor={p.label}
                style={{ textTransform: 'capitalize' }}
                fontSize={'sm'}
            >
                {p.title}
            </FormLabel>

            <InputGroup size="md">
                <Input
                    isDisabled={p.isDisabled}
                    readOnly={p.readOnly}
                    type={p.type}
                    bg={'white'}
                    max={p.maxInput}
                    min={p.minInput}
                    placeholder={p.placeholder || `Ketik ${p.title}`}
                    onClick={p.onClickInput}
                    {...p.register(p.label, {
                        required: p.required,
                        setValueAs: p.setValueAs,
                        validate: p.validate,
                        pattern: p.pattern,
                        max: p.max,
                        // valueAsNumber: p.valueAsNumber ? true : false,
                        // valueAsDate: p.valueAsDate ? true : false,
                    })}
                />
                <InputRightElement width="4.5rem">{p.rChild}</InputRightElement>
            </InputGroup>
            <FormErrorMessage>
                <>{p.errors && p.errors}</>
            </FormErrorMessage>
        </FormControl>
    )
}

function FormInput<T extends object>(
    p: InputPropsT<T>,
    ref?: React.Ref<HTMLInputElement>
) {
    return (
        <FormControl key={p.label} isInvalid={!!p.errors}>
            <FormLabel
                htmlFor={p.label}
                style={{ textTransform: 'capitalize' }}
                fontSize={'sm'}
            >
                {p.title}
            </FormLabel>
            <Input
                isDisabled={p.isDisabled}
                readOnly={p.readOnly}
                type={p.type}
                bg={'white'}
                max={p.maxInput}
                min={p.minInput}
                placeholder={p.placeholder || `Ketik ${p.title}`}
                onClick={p.onClickInput}
                {...p.register(p.label, {
                    required: p.required,
                    setValueAs: p.setValueAs,
                    validate: p.validate,
                    pattern: p.pattern,
                    max: p.max,
                    // valueAsNumber: p.valueAsNumber ? true : false,
                    // valueAsDate: p.valueAsDate ? true : false,
                })}
            />

            <FormErrorMessage>
                <>{p.errors && p.errors}</>
            </FormErrorMessage>
        </FormControl>
    )
}

export const FormControls = React.forwardRef(FormInput) as unknown as <
    T extends object
>(
    p: InputPropsT<T> & { ref?: React.Ref<HTMLInputElement> }
) => React.ReactElement

export const FormControlNumber = <T extends object>(props: InputPropsT<T>) => {
    return (
        <FormControl key={props.label} isInvalid={!!props.errors}>
            <FormLabel
                htmlFor={props.label}
                style={{ textTransform: 'capitalize' }}
                fontSize={'sm'}
            >
                {props.title}
            </FormLabel>
            <Controller
                rules={{
                    required: props.required,
                    validate: props.validate,
                    // minLength: props.minLength || 3,
                }}
                name={props.label}
                control={props.control}
                render={({ field: { onChange, value, ref } }) => (
                    <NumericFormat
                        value={Number(value)}
                        customInput={Input}
                        placeholder={`Ketik ${props.title}`}
                        getInputRef={ref}
                        max={props.maxInput}
                        thousandSeparator="."
                        decimalSeparator=","
                        prefix="Rp. "
                        onValueChange={(target) => onChange({ target })}
                    />
                )}
            />
            <FormErrorMessage>
                <>{props.errors && props.errors}</>
            </FormErrorMessage>
        </FormControl>
    )
}

export const FormControlNumbers = <T extends object>(props: InputPropsT<T>) => {
    return (
        <FormControl key={props.label} isInvalid={!!props.errors}>
            <FormLabel
                htmlFor={props.label}
                style={{ textTransform: 'capitalize' }}
                fontSize={'sm'}
            >
                {props.title}
            </FormLabel>
            <Controller
                rules={{
                    required: props.required,
                    validate: props.validate,
                }}
                name={props.label}
                control={props.control}
                render={({ field: { onChange, value, ref } }) => (
                    <NumericFormat
                        value={Number(value)}
                        customInput={Input}
                        placeholder={`Ketik ${props.title}`}
                        getInputRef={ref}
                        max={props.maxInput}
                        onValueChange={(target) => onChange({ target })}
                    />
                )}
            />
            <FormErrorMessage>
                <>{props.errors && props.errors}</>
            </FormErrorMessage>
        </FormControl>
    )
}

export const FormSelects = <T extends object, S>({
    label,
    errors,
    isMulti,
    control,
    loadOptions,
    isDisabled,
    async,
    options,
    placeholder,
    title,
    defaultValue,
    required,
    defaultOptions = true,
}: // components,
SelectsPropsT<T, S>) => {
    return (
        <FormControl isInvalid={!!errors} className="select-wrapper">
            <FormLabel
                as={'label'}
                htmlFor={label}
                fontSize={'sm'}
                textTransform={'capitalize'}
            >
                {title}
            </FormLabel>
            <Controller
                control={control}
                name={label}
                rules={{ required }}
                render={({ field }) => (
                    <>
                        {async ? (
                            <AsyncSelect
                                defaultOptions={defaultOptions}
                                isDisabled={isDisabled}
                                formatOptionLabel={(p) => {
                                    if (p.image) {
                                        return (
                                            <HStack fontSize={'sm'}>
                                                {p.image && (
                                                    <Avatar
                                                        src={p.image}
                                                        name={p.label}
                                                        size="sm"
                                                    />
                                                )}
                                                <VStack
                                                    align={'start'}
                                                    spacing={0}
                                                >
                                                    <Text>{p.label}</Text>
                                                    <Text>{p.extra}</Text>
                                                </VStack>
                                            </HStack>
                                        )
                                    }

                                    return <Text>{p.label}</Text>
                                }}
                                cacheOptions={false}
                                defaultValue={defaultValue}
                                loadOptions={loadOptions}
                                isClearable={true}
                                isMulti={isMulti}
                                placeholder={placeholder || 'Cari sesuatu...'}
                                onChange={field.onChange}
                                styles={customStyles}
                            />
                        ) : (
                            <Select
                                {...field}
                                isDisabled={isDisabled}
                                name={label}
                                inputId={label}
                                options={options}
                                isMulti={isMulti}
                                isClearable={true}
                                formatOptionLabel={(p) => (
                                    <HStack>
                                        {p.image && (
                                            <Avatar
                                                key={p.value}
                                                src={p.image}
                                                name={p.label}
                                                size="sm"
                                            />
                                        )}
                                        <span>{p.label}</span>
                                    </HStack>
                                )}
                                defaultValue={defaultValue}
                                placeholder={placeholder || 'Cari sesuatu...'}
                                styles={customStyles}
                                menuPortalTarget={document.body}
                                menuPosition={'fixed'}
                            />
                        )}
                    </>
                )}
            />
            <FormErrorMessage>{errors && errors}</FormErrorMessage>
        </FormControl>
    )
}

export const FormSelectsChakra = <T extends object, S>({
    label,
    errors,
    isMulti,
    control,
    loadOptions,
    isDisabled,
    async,
    options,
    placeholder,
    title,
    defaultValue,
    required,
    defaultOptions = true,
}: // components,
SelectsPropsT<T, S>) => {
    return (
        <FormControl isInvalid={!!errors} className="select-wrapper">
            <FormLabel
                as={'label'}
                htmlFor={label}
                fontSize={'sm'}
                textTransform={'capitalize'}
            >
                {title}
            </FormLabel>
            <Controller
                control={control}
                name={label}
                rules={{ required }}
                render={({ field }) => (
                    <>
                        {async ? (
                            <AsyncSelect
                                defaultOptions={defaultOptions}
                                isDisabled={isDisabled}
                                formatOptionLabel={(p) => {
                                    if (p.image) {
                                        return (
                                            <HStack fontSize={'sm'}>
                                                {p.image && (
                                                    <Avatar
                                                        src={p.image}
                                                        name={p.label}
                                                        size="sm"
                                                    />
                                                )}
                                                <VStack
                                                    align={'start'}
                                                    spacing={0}
                                                >
                                                    <Text>{p.label}</Text>
                                                    <Text>{p.extra}</Text>
                                                </VStack>
                                            </HStack>
                                        )
                                    }

                                    return <Text>{p.label}</Text>
                                }}
                                cacheOptions={false}
                                defaultValue={defaultValue}
                                loadOptions={loadOptions}
                                isMulti={isMulti}
                                placeholder={placeholder || 'Cari sesuatu...'}
                                onChange={field.onChange}
                                styles={customStyles}
                            />
                        ) : (
                            <Select
                                {...field}
                                isDisabled={isDisabled}
                                name={label}
                                inputId={label}
                                options={options}
                                isMulti={isMulti}
                                formatOptionLabel={(p) => (
                                    <HStack>
                                        {p.image && (
                                            <Avatar
                                                key={p.value}
                                                src={p.image}
                                                name={p.label}
                                                size="sm"
                                            />
                                        )}
                                        <span>{p.label}</span>
                                    </HStack>
                                )}
                                defaultValue={defaultValue}
                                placeholder={placeholder || 'Cari sesuatu...'}
                                styles={customStyles}
                            />
                        )}
                    </>
                )}
            />
            <FormErrorMessage>{errors && errors}</FormErrorMessage>
        </FormControl>
    )
}

export const FormControlsTextArea = <T extends object>(
    props: InputPropsT<T>
) => {
    return (
        <FormControl isInvalid={!!props.errors}>
            <FormLabel
                htmlFor={props.label}
                style={{ textTransform: 'capitalize' }}
                fontSize={'sm'}
            >
                {props.title}
            </FormLabel>
            <Textarea
                isDisabled={props.isDisabled}
                readOnly={props.readOnly}
                bg={'white'}
                minH={'150px'}
                maxH={'150px'}
                focusBorderColor={'red.200'}
                placeholder={
                    props.placeholder
                        ? props.placeholder
                        : `Ketik ${props.title}`
                }
                resize={'none'}
                onClick={props.onClickArea}
                {...props.register(props.label, {
                    required: props.required,
                    setValueAs: props.setValueAs,
                    validate: props.validate,
                    pattern: props.pattern,
                    max: props.max,
                    // valueAsNumber: props.valueAsNumber ? true : false,
                    // valueAsDate: props.valueAsDate ? true : false,
                })}
            />
            <FormErrorMessage>
                <>{props.errors && props.errors}</>
            </FormErrorMessage>
        </FormControl>
    )
}
interface LoadingFormProps {
    lenData?: number
}

export const LoadingForm: React.FC<LoadingFormProps> = ({ lenData }) => {
    const arr = Array.from({ length: lenData || 6 }, (_, i) => i)

    return (
        <>
            <SimpleGrid columns={2} gap={5} pb={5}>
                {arr.map((i) => (
                    <Skeleton key={i} height="25px" rounded={'sm'} />
                ))}
            </SimpleGrid>
        </>
    )
}

export const LoadingCard = () => (
    <Box
        bg="white"
        p={2}
        rounded={'md'}
        mb={3}
        h={'100px'}
        experimental_spaceY={4}
    >
        <SimpleGrid columns={4} gap={3}>
            {[1, 2, 3, 4, 5, 6, 7].map((i) => (
                <>
                    <Skeleton height={'40px'} />
                    <Skeleton height={'40px'} />
                    <Skeleton height={'40px'} />
                    <Skeleton height={'40px'} />
                </>
            ))}
        </SimpleGrid>
    </Box>
)

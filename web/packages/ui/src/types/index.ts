import type {
    ButtonProps,
    InputGroupProps,
    InputProps,
    TextareaProps,
    ModalProps,
    ModalContentProps,
    ResponsiveValue,
} from '@chakra-ui/react'
import React, { MouseEventHandler, ReactNode } from 'react'
import type {
    Control,
    FieldError,
    FieldErrorsImpl,
    Merge,
    Path,
    PathValue,
    UseFormRegister,
    Validate,
    ValidationRule,
} from 'react-hook-form'

export type appName = 'System' | 'Branch' | 'Sales' | 'Finance' | 'Warehouse'

export interface Columns<T extends object, V = React.ReactNode> {
    render(type: T): React.ReactNode
    header: V
    width?: string | number
}

export interface TableProps<T extends object> {
    columns: Columns<T>[]
    data: T[]
    usePaging?: boolean
    isLoading?: boolean
    pageH?: string
    useTab?: boolean
}

export type InputPropsT<T extends object> = {
    label: Path<T>
    control?: Control<T, any>
    title?: string
    register: UseFormRegister<T>
    maxInput?: number | string
    minInput?: number | string
    required?: string | ValidationRule<boolean> | undefined
    errors?:
        | string
        | FieldError
        | Merge<FieldError, FieldErrorsImpl<any>>
        | undefined
    MAX_LIMIT?: number
    MIN_LIMIT?: number
    validate?:
        | Validate<PathValue<T, Path<T>>, T>
        | Record<string, Validate<PathValue<T, Path<T>>, T>>
        | undefined
    setValueAs?: (value: any) => any
    pattern?: ValidationRule<RegExp> | undefined
    max?: ValidationRule<string | number>
    rChild?: React.ReactNode
    placeholder?: string
    valueAsNumber?: boolean
    valueAsDate?: boolean
    format?: string
    type?: React.HTMLInputTypeAttribute
    isDisabled?: boolean
    readOnly?: boolean
    minLength?: number
    onChange?: React.ChangeEventHandler<HTMLInputElement>
    onClickInput?: React.MouseEventHandler<HTMLInputElement>
    onClickArea?: React.MouseEventHandler<HTMLTextAreaElement>
}

export interface ListSidebarProps {
    id: number
    title: string
    link: string
}

export interface SidebarProps {
    items: ListSidebarProps[] | undefined
    backUrl: string
    activeNum: number
}

type MotionPreset = 'slideInBottom' | 'slideInRight' | 'scale' | 'none'

export type ModalsTypes = {
    isOpen: boolean
    setOpen(v: boolean): void
    title?: string
    children?: ReactNode
    onDelete?: React.MouseEventHandler<HTMLButtonElement> | undefined
    size?:
        | 'xs'
        | 'sm'
        | 'md'
        | 'lg'
        | 'xl'
        | '2xl'
        | '3xl'
        | '4xl'
        | '5xl'
        | '6xl'
        | 'full'
    scrlBehavior?: 'inside' | 'outside'
    motion?: MotionPreset | undefined
    backdropFilter?: string
} & ModalContentProps

export type SelectsPropsT<T extends object, S> = {
    label: Path<T>
    errors?: string
    isMulti?: boolean
    control: Control<T>
    isDisabled?: boolean
    components?: Partial<T>
    loadOptions?(inputValue: string): Promise<S[]>
    async?: boolean
    required?: string | ValidationRule<boolean> | undefined
    options?: any[]
    title?: string
    placeholder?: string
    defaultValue?: any
    defaultOptions?: boolean
}

export interface InputWithButtonProps extends InputGroupProps {
    onChange?: React.ChangeEventHandler<HTMLInputElement> | undefined
    btnOnclick: MouseEventHandler<HTMLButtonElement> | undefined
    valueInput?: string
    label: string
    btnLabel?: string
}

export interface InputsProps extends InputProps {
    label: string
}

export interface InputSearchProps extends InputGroupProps {
    text: string
    onChange?: React.ChangeEventHandler<HTMLInputElement> | undefined
    valueInput?: string
    btnLabel?: string
}

export interface ListItemProps {
    id?: number
    icon: ReactNode
    color: string
    text: string
    link: string
}

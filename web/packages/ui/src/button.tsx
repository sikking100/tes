import { ArrowUpIcon, InfoIcon, SearchIcon } from '@chakra-ui/icons'
import {
    Tooltip,
    Button,
    ButtonProps,
    IconButton,
    IconButtonProps,
} from '@chakra-ui/react'
import React from 'react'
import { FC, ReactElement } from 'react'

import { DiscountIcons, IconsProduct, PencilIcons, TrashIcons } from './icons'

interface IButton extends ButtonProps {
    label: string
}

export const Buttons: FC<IButton> = (props) => {
    const { label, leftIcon, ...rest } = props
    return (
        <Button
            data-testid="button-test"
            bg={'red.200'}
            fontSize={'sm'}
            leftIcon={leftIcon}
            {...rest}
        >
            {label}
        </Button>
    )
}

type ButtonTooltipProps = {
    label: string
    icon: React.ReactElement
    onClick?: () => void
    isDisabled?: boolean
    bg?: string
    isLoading?: boolean
}

export const ButtonTooltip: React.FC<ButtonTooltipProps> = ({
    icon,
    label,
    onClick,
    isDisabled,
    bg,
    isLoading,
}) => (
    <Tooltip label={label}>
        <IconButton
            shadow={'none'}
            aria-label={label}
            icon={icon as any}
            isDisabled={isDisabled}
            onClick={onClick}
            bg={bg}
            isLoading={isLoading}
        />
    </Tooltip>
)

interface IIconButtons extends IconButtonProps {
    what?: 'edit' | 'delete' | 'discount' | 'search' | 'product' | string
}

export const ButtonIcons: FC<IIconButtons> = (props: IIconButtons) => {
    const { what, ...rest } = props
    return (
        <Tooltip
            label={
                what == 'edit'
                    ? 'Edit'
                    : what === 'delete'
                    ? 'Delete'
                    : what === 'discount'
                    ? 'Promo'
                    : what === 'product'
                    ? 'Product'
                    : what
            }
        >
            <IconButton
                // aria-label={String(what)}
                icon={
                    what === 'edit' ? (
                        <PencilIcons color={'gray'} fontSize={20} />
                    ) : what === 'delete' ? (
                        <TrashIcons color={'gray'} />
                    ) : what === 'discount' ? (
                        <DiscountIcons color={'gray'} fontSize={20} />
                    ) : what === 'search' ? (
                        <InfoIcon color={'gray'} fontSize={20} />
                    ) : what === 'product' ? (
                        <IconsProduct color={'gray'} />
                    ) : (
                        <InfoIcon color={'gray'} />
                    )
                }
                {...rest}
            />
        </Tooltip>
    )
}

interface IButtonUpload extends ButtonProps {
    onChangeInput?: React.ChangeEventHandler<HTMLInputElement>
    label: string
}

export const ButtonUpload: FC<IButtonUpload> = (props) => {
    const { onChangeInput, label, ...rest } = props
    return (
        <>
            <input
                type="file"
                accept="image/*"
                id={'upload-btn'}
                style={{ display: 'none' }}
                multiple={false}
                onChange={onChangeInput}
            />

            <label htmlFor={'upload-btn'}>
                <Buttons label={label} leftIcon={<ArrowUpIcon />} {...rest} />
            </label>
        </>
    )
}

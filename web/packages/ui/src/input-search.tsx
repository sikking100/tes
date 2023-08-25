import { HStack, Tooltip } from '@chakra-ui/react'
import React, { FC } from 'react'
import { useNavigate } from 'react-router-dom'

import { AddIcons } from './icons'
import { Buttons } from './button'
import { InputSearch } from './input'
import { CsvParse } from './csv-reader'

interface SearchInputProps {
    labelBtn?: string
    placeholder?: string
    placeholderBtnExport?: string
    onClick?: () => void
    link?: string
    onChange?: React.ChangeEventHandler<HTMLInputElement>
    onKeyPress?: React.KeyboardEventHandler<HTMLDivElement>
    onClickBtnExp?: (i: any[]) => void
    isShowBtn?: boolean
}

export const SearchInput: FC<SearchInputProps> = React.memo(
    ({
        labelBtn,
        placeholder,
        link,
        onChange,
        onKeyPress,
        onClickBtnExp,
        placeholderBtnExport,
        isShowBtn,
        onClick,
    }) => {
        // const isShow = isShowBtn === undefined ? true : isShowBtn
        const navigate = useNavigate()

        const Btn = () => {
            const onClicks = () => {
                //(onClick ? onClick : navigate(`${link}`))
                if (onClick) {
                    onClick()
                } else {
                    navigate(`${link}`)
                }
            }
            return (
                <Buttons
                    leftIcon={<AddIcons />}
                    label={labelBtn || 'Tambahkan Data'}
                    onClick={onClicks}
                />
            )
        }

        return (
            <HStack w="full" spacing={3} mb={3}>
                <InputSearch
                    text=""
                    placeholder={placeholder || 'Cari Sesuatu ...'}
                    onChange={onChange}
                    onKeyPress={onKeyPress}
                />
                {link && <Btn />}
                {onClickBtnExp && (
                    <Tooltip label={placeholderBtnExport || 'Import Data'}>
                        <CsvParse child={<></>} cb={(i) => onClickBtnExp(i)} />
                    </Tooltip>
                )}
            </HStack>
        )
    }
)

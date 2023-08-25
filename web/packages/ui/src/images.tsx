import React from 'react'
import { Image, ImageProps } from '@chakra-ui/image'
import { Box, Text } from '@chakra-ui/layout'
import { FC } from 'react'

type IImageProps = {
    label?: string
} & ImageProps

export const Images: FC<IImageProps> = (props) => {
    const { label, ...rest } = props
    return (
        <Box>
            <Text mb={'5px'} fontWeight={'500'} fontSize={'sm'}>
                {label}
            </Text>
            <Image {...rest} src={props.src} />
        </Box>
    )
}

interface ImageTypesProps extends ImageProps {
    onChangeInput?: React.ChangeEventHandler<HTMLInputElement> | undefined
    imageUrl: string
    title: string
    idImage?: string
}

export const ImagePick: FC<ImageTypesProps> = (props: ImageTypesProps) => {
    const { imageUrl, onChangeInput, title, idImage, ...rest } = props
    return (
        <Box>
            <Text mb={'5px'} fontSize={'sm'} fontWeight={500}>
                {title}
            </Text>
            <input
                data-testid={'image-test'}
                type="file"
                accept="image/*"
                id={idImage || 'image'}
                style={{ display: 'none' }}
                multiple={false}
                onChange={onChangeInput}
            />

            <label htmlFor={idImage || 'image'}>
                <Image
                    boxSize="150px"
                    objectFit="cover"
                    src={imageUrl}
                    alt="Image"
                    rounded="md"
                    _hover={{ cursor: 'pointer' }}
                    {...rest}
                />
            </label>
        </Box>
    )
}

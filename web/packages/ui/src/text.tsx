import { Text as TextChakra, TextProps } from '@chakra-ui/layout'
import React from 'react'

type Props = {
  label: string
  h: string
}

interface PTextPRops extends TextProps {
  label: string
}

export const Texts: React.FC<Props> = ({ h, label }) => {
  return (
    <TextChakra fontSize={'16px'}>
      {label}{' '}
      <TextChakra fontWeight={'bold'} as={'span'}>
        {h}
      </TextChakra>{' '}
      ?
    </TextChakra>
  )
}

export const PText: React.FC<PTextPRops> = (props) => {
  const { label, ...rest } = props
  return (
    <TextChakra fontSize={'16px'} fontWeight={500} as={'p'} {...rest}>
      {label}
    </TextChakra>
  )
}

export const TextWarning = () => (
  <TextChakra color={'red'} fontSize={'xs'}>
    *Peringatan! Jika Memasukkan ID Yang Sudah Digunakan, Maka Data Akan Tertimpa
  </TextChakra>
)

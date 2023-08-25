import { Highlight, Text, Box } from '@chakra-ui/layout'
import React from 'react'
import { ButtonForm } from '../button-form'
import { Modals } from '../modals'

interface ModalDeleteProps {
    desc: string
    isOpen: boolean
    setOpen: () => void
    onClick: () => void
    onClose: () => void
    isLoading: boolean
    title?: string
    addsText?: boolean
}

const ModalDelete: React.FC<ModalDeleteProps> = (props) => {
    const title = props.title || props.desc
    return (
        <Modals
            title={`Hapus ${title}`}
            isOpen={props.isOpen}
            setOpen={props.setOpen}
        >
            <Box>
                {!props.addsText ? (
                    <Highlight query={props.desc} styles={{ fontWeight: 600 }}>
                        {`Jika melanjutkan proses ini, data ${props.desc} akan terhapus secara permanen. Ingin
melanjutkan ?`}
                    </Highlight>
                ) : (
                    <Text>{props.desc}</Text>
                )}
            </Box>
            <ButtonForm
                isLoading={props.isLoading}
                label="Hapus"
                onClick={props.onClick}
                onClose={props.onClose}
            />
        </Modals>
    )
}

export default ModalDelete

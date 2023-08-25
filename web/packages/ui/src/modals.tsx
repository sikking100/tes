import React from 'react'
import { Button } from '@chakra-ui/button'
import {
    Modal,
    ModalBody,
    ModalCloseButton,
    ModalContent,
    ModalFooter,
    ModalHeader,
    ModalOverlay,
} from '@chakra-ui/modal'

import { ModalsTypes } from './types'

export const Modals: React.FC<ModalsTypes> = (props) => {
    const {
        isOpen,
        setOpen,
        children,
        onDelete,
        title,
        size = '2xl',
        scrlBehavior = 'inside',
        backdropFilter = 'blur(10px)',
        ...rest
    } = props

    const onCLose = () => {
        setOpen(false)
    }

    return (
        <Modal
            isCentered
            isOpen={isOpen}
            size={size}
            onClose={onCLose}
            scrollBehavior={scrlBehavior}
            motionPreset={props.motion || 'slideInBottom'}
            lockFocusAcrossFrames={true}
        >
            <ModalOverlay bg="blackAlpha.300" backdropFilter={backdropFilter} />
            <ModalContent rounded={'xl'} {...rest}>
                <ModalHeader>{title}</ModalHeader>
                <ModalCloseButton />
                <ModalBody>
                    <>{children}</>
                </ModalBody>

                {onDelete && (
                    <ModalFooter>
                        <Button bg={'red.200'} onClick={onDelete}>
                            Delete
                        </Button>
                    </ModalFooter>
                )}
            </ModalContent>
        </Modal>
    )
}

import { HStack, Text, Badge, BadgeProps } from '@chakra-ui/layout'
import { Image } from '@chakra-ui/react'

interface StackAvatarProps {
    imageUrl: string
    name: string
}

interface BadgesProps extends BadgeProps {
    status: string
}

export const StackAvatar: React.FC<StackAvatarProps> = ({ imageUrl, name }) => {
    return (
        <HStack w={'fit-content'}>
            <Image
                src={imageUrl}
                w="40px"
                h="40px"
                objectFit={'contain'}
                rounded={'lg'}
            />
            <Text w={'10em'} textTransform={'capitalize'}>
                {name.toLowerCase()}
            </Text>
        </HStack>
    )
}

export const Badges: React.FC<BadgesProps> = (props) => {
    const { status, ...rest } = props

    const setStatus = () => {
        switch (status) {
            case 'PENDING':
                return 'yellow'
            case 'APPROVE':
                return 'green'
            case 'REJECT':
                return 'red'
            default:
                return 'gray'
        }
    }

    return (
        <Badge
            colorScheme={setStatus()}
            fontSize={'13px'}
            rounded={'lg'}
            px={2}
            py={1}
            {...rest}
        >
            {status}
        </Badge>
    )
}

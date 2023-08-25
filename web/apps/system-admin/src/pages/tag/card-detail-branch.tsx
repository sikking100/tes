import React from 'react'
import { Box, Text } from '@chakra-ui/react'
import { useParams, useSearchParams } from 'react-router-dom'
import { PText } from 'ui'
import { branchService } from 'hooks'

const CardDetailBranch: React.FC<{ type?: 'price' | 'qty' }> = ({ type }) => {
    const params = useParams()
    const [searchParams] = useSearchParams()
    const { data, error, isLoading } = branchService.useGetBranchId(`${searchParams.get('branchId') || params.id}`)

    const findWarehouse = () => {
        const wFind = data?.warehouse.find((v) => v.isDefault)
        if (wFind) {
            return wFind
        }
        return null
    }

    return (
        <Box mb={2} bg="white" px={3} py={2} rounded={'xl'} w="full">
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <Text>Loading...</Text>
            ) : (
                <React.Fragment>
                    <Box>
                        <Text fontWeight={'semibold'} fontSize={'lg'}>
                            {data?.name}
                        </Text>
                        {type === 'price' && (
                            <Text fontWeight={'semibold'} fontSize={'sm'}>
                                {data?.address.name}
                            </Text>
                        )}
                        {type === 'qty' && (
                            <Text fontWeight={'semibold'} fontSize={'sm'}>
                                {findWarehouse()?.name}
                            </Text>
                        )}
                    </Box>
                </React.Fragment>
            )}
        </Box>
    )
}

export default CardDetailBranch

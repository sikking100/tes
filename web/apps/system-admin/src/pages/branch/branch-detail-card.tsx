import React from 'react'
import { Box, Divider, Text } from '@chakra-ui/react'
import { branchService } from 'hooks'
import { LoadingForm, PText, MapsPickLocation } from 'ui'

const BranchDetailsCard: React.FC<{ id: string }> = ({ id }) => {
    const { data, error, isLoading } = branchService.useGetBranchId(id)

    return (
        <Box bg="white" pb={3}>
            {error ? (
                <PText label={error} />
            ) : isLoading ? (
                <LoadingForm />
            ) : (
                <React.Fragment>
                    <Box>
                        <MapsPickLocation
                            height="30vh"
                            currentLoc={(e) => console.log(e)}
                            lat={Number(data?.address.lngLat[1])}
                            lng={Number(data?.address.lngLat[0])}
                        />
                    </Box>

                    <Divider my={3} />
                    <Box experimental_spaceY={2}>
                        <Box>
                            <Text fontSize={'sm'}>ID Cabang</Text>
                            <Text fontSize={'md'} fontWeight={'semibold'}>
                                {data?.id}
                            </Text>
                        </Box>
                        <Box>
                            <Text fontSize={'sm'}>Nama Cabang</Text>
                            <Text fontSize={'md'} fontWeight={'semibold'}>
                                {data?.name}
                            </Text>
                        </Box>

                        <Box>
                            <Text fontSize={'sm'}>Alamat</Text>
                            <Text fontSize={'md'} fontWeight={'semibold'}>
                                {data?.address.name}
                            </Text>
                        </Box>
                    </Box>
                </React.Fragment>
            )}
        </Box>
    )
}

export default BranchDetailsCard

import { Avatar, Box, HStack, Text, VStack } from '@chakra-ui/react'
import { fbFirestore } from 'apis'
import { deliveryService } from 'hooks'
import React from 'react'
import { useParams } from 'react-router-dom'
import { MapsTracking, Root } from 'ui'

interface TrackingDelivery {
    courier: {
        heading: number
        lat: number
        lng: number
    }
    customer: {
        lat: number
        lng: number
    }
    deliveryId: string
    expiredAt: number
    overviewPolyline: string
}

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="Warehouse" items={[]} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const DetailDelivery = () => {
    const params = useParams()
    const [dataTracking, setDataTracking] = React.useState<{ lat: number; lng: number }[]>([])
    const [stops, setStops] = React.useState<{ lat: number; lng: number }[]>([])
    const { data: delivery, isLoading } = deliveryService.useGetDeliveryById(`${params.deliveryId}`)

    const getTracking = async () => {
        const db = fbFirestore.collection('tracking').doc(`${params.deliveryId}`)
        db.onSnapshot((doc) => {
            if (doc.exists) {
                const data = doc.data() as TrackingDelivery
                setDataTracking([
                    {
                        lat: data.courier.lat,
                        lng: data.courier.lng,
                    },
                ])
                setStops([
                    {
                        lat: data.customer.lat,
                        lng: data.customer.lng,
                    },
                ])
            }
        })
    }

    React.useEffect(() => {
        getTracking()
    }, [])

    if (dataTracking.length < 1 || isLoading) return <Wrap>Loading...</Wrap>

    return (
        <Wrap>
            {delivery && (
                <>
                    <Box bg="white" rounded={'lg'} p={'10px'} w={'30rem'} mr={'10px'} zIndex={10} pos={'absolute'}>
                        <Box>
                            <HStack w="full">
                                <Avatar src={delivery.courier.imageUrl} name={delivery.courier.name} size={'xl'} />
                                <VStack align={'start'} spacing={1}>
                                    <Text>{delivery.courier.id}</Text>
                                    <Text fontWeight={'bold'} fontSize={'lg'}>
                                        {delivery.courier.name}
                                    </Text>
                                    <Text>{delivery.courier.phone}</Text>
                                </VStack>
                            </HStack>
                        </Box>
                    </Box>
                    <MapsTracking
                        stops={stops?.map((v) => ({ lat: v.lat, lng: v.lng }))}
                        path={dataTracking?.map((v) => ({ lat: v.lat, lng: v.lng }))}
                    />
                </>
            )}
        </Wrap>
    )
}

export default DetailDelivery

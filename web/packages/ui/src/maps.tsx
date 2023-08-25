import './maps.css'
import React from 'react'
import { Input } from '@chakra-ui/input'
import { Box, Button } from '@chakra-ui/react'
import {
    GoogleMap,
    Marker,
    StandaloneSearchBox,
    useJsApiLoader,
    DirectionsRenderer,
    Polyline,
} from '@react-google-maps/api'
import { configs } from 'apis'

interface LatLngProps {
    lat: number
    lng: number
    address: string
}
export interface MapsPickLocationTypes {
    origin?: LatLngProps
    dest?: LatLngProps
    lat?: number
    lng?: number
    address?: string
    currentLoc: (i: LatLngProps) => void
    height?: string
}
// const API_KEY = 'AIzaSyC-Uji8Ri4-nX59yTWwPOsHMmCRCKgurfo'

export const MapsPickLocation: React.FC<MapsPickLocationTypes> = ({
    lat = 0,
    lng = 0,
    address = '',
    currentLoc,
    height = '100%',
    dest,
    origin,
}) => {
    const inputRef = React.useRef<any>(null)
    const [directionsResponse, setDirectionsResponse] =
        React.useState<google.maps.DirectionsResult | null>(null)
    const [defaultLang, UpdateDefaultLang] = React.useState({
        lat,
        lng,
        address,
    })

    const { isLoaded } = useJsApiLoader({
        id: 'google-map-script',
        googleMapsApiKey: configs().mapsKey,
        libraries: ['places'],
    })

    React.useEffect(() => {
        navigator.geolocation.getCurrentPosition((position) => {
            const lat = position.coords.latitude
            const lng = position.coords.longitude
            UpdateDefaultLang({ lat, lng, address: '' })
        })
    }, [lat, lng, address, directionsResponse])

    React.useEffect(() => {
        if (origin && dest) {
            calculateRoutes()
        }
    }, [origin, dest])

    const calculateRoutes = async () => {
        const icons = {
            start: new google.maps.Marker({
                label: 'Kurir',
            }),
            end: new google.maps.Marker({
                label: 'Pelanggan',
            }),
        }

        const directionsDisplay = new google.maps.DirectionsRenderer({
            markerOptions: {
                icon: 'put_here_the_url_to_your_icon',
            },
        })

        const directionsService = new google.maps.DirectionsService()
        const results = await directionsService.route({
            origin: { lat: Number(origin?.lat), lng: Number(origin?.lng) },
            destination: { lat: Number(dest?.lat), lng: Number(dest?.lng) },
            travelMode: google.maps.TravelMode.DRIVING,
        })
        setDirectionsResponse(results)
    }

    const geoLocationFunc = (lat: number, lng: number) => {
        const geocoder = new google.maps.Geocoder()
        const latlng = new google.maps.LatLng(lat, lng)

        return new Promise<LatLngProps>((resolve, reject) => {
            return geocoder.geocode({ location: latlng }, (results, status) => {
                if (results) {
                    if (status !== google.maps.GeocoderStatus.OK) {
                        reject(`Status, ${status}`)
                    }
                    if (status == google.maps.GeocoderStatus.OK) {
                        resolve({
                            address: results[0].formatted_address,
                            lat: results[0].geometry.location.lat(),
                            lng: results[0].geometry.location.lng(),
                        })
                    }
                }
            })
        })
    }

    const handlePlaceChanged = async () => {
        const [place] = inputRef.current?.getPlaces()
        const getLocation = await geoLocationFunc(
            place.geometry.location.lat(),
            place.geometry.location.lng()
        )

        UpdateDefaultLang({ ...getLocation })
        currentLoc({ ...getLocation })
    }

    const HandleEventOnclick = async (e: google.maps.MapMouseEvent) => {
        const getLocation = await geoLocationFunc(
            Number(e?.latLng?.lat()),
            Number(e?.latLng?.lng())
        )
        UpdateDefaultLang({ ...getLocation })
        currentLoc({ ...getLocation })
    }

    const HandleOndrag = async (e: google.maps.MapMouseEvent) => {
        const getLocation = await geoLocationFunc(
            Number(e?.latLng?.lat()),
            Number(e?.latLng?.lng())
        )
        UpdateDefaultLang({ ...getLocation })
        currentLoc({ ...getLocation })
    }

    return isLoaded ? (
        <>
            <Box position="relative" left={0} top={0} h="100%" w="100%">
                <StandaloneSearchBox
                    onLoad={(ref) => (inputRef.current = ref)}
                    onPlacesChanged={handlePlaceChanged}
                >
                    <Input type="text" width="100%" placeholder="Cari Lokasi" />
                </StandaloneSearchBox>
                <GoogleMap
                    clickableIcons
                    mapContainerStyle={{
                        width: '100%',
                        height: height,
                    }}
                    center={defaultLang}
                    zoom={16}
                    onClick={HandleEventOnclick}
                >
                    <Marker
                        draggable
                        position={defaultLang}
                        onClick={HandleEventOnclick}
                        onDrag={HandleOndrag}
                    />
                    {directionsResponse && (
                        <DirectionsRenderer directions={directionsResponse} />
                    )}
                </GoogleMap>
            </Box>
        </>
    ) : (
        <p>Load Maps</p>
    )
}

interface IMaps {
    path: any[]
    stops: any[]
}

const DotsPulse = () => (
    <div className="pulse-container">
        <div className="pulse-box">
            <svg
                className="pulse-svg"
                width="50px"
                height="50px"
                viewBox="0 0 50 50"
                version="1.1"
                xmlns="http://www.w3.org/2000/svg"
            >
                <circle
                    className="circle first-circle"
                    fill="#FF6347"
                    cx="25"
                    cy="25"
                    r="25"
                ></circle>
                <circle
                    className="circle second-circle"
                    fill="#FF6347"
                    cx="25"
                    cy="25"
                    r="25"
                ></circle>
                <circle
                    className="circle third-circle"
                    fill="#FF6347"
                    cx="25"
                    cy="25"
                    r="25"
                ></circle>
                <circle
                    className="circle fourth-circle"
                    fill="#FF6347"
                    cx="25"
                    cy="25"
                    r="25"
                ></circle>
            </svg>
        </div>
    </div>
)

export const MapsTracking: React.FC<IMaps> = ({ path, stops }) => {
    const { isLoaded } = useJsApiLoader({
        id: 'google-map-script',
        googleMapsApiKey: configs().mapsKey,
        libraries: ['places', 'geometry', 'drawing'],
        region: 'ID',
    })
    const [directions, setDirections] = React.useState<any>(null)
    let paths: any[] = path
    const [progress, setProgress] = React.useState<any[]>([])
    const velocity = 27 // 100km per hour
    let initialDate = Date.now()
    let interval: any = null
    const center = parseInt(`${paths.length / 2}`)
    const centerPathLat = paths[0].lat
    const centerpathLng = paths[0].lng

    const urlIcon = '/img-vihecle.png'

    // const icon1 = {
    //     url: 'https://images.vexels.com/media/users/3/154573/isolated/preview/bd08e000a449288c914d851cb9dae110-hatchback-car-top-view-silhouette-by-vexels.png',
    //     scale: 0.7,
    //     scaledSize: 0.1,
    //     anchor: 10,
    // }

    React.useEffect(() => {
        if (isLoaded) {
            const directionsService = new window.google.maps.DirectionsService()
            directionsService.route(
                {
                    origin: new window.google.maps.LatLng(
                        centerPathLat,
                        centerpathLng
                    ),
                    destination: new window.google.maps.LatLng(
                        stops[0].lat,
                        stops[0].lng
                    ),
                    travelMode: window.google.maps.TravelMode.DRIVING,
                },
                (result, status) => {
                    if (status === google.maps.DirectionsStatus.OK) {
                        setDirections(result)
                    } else {
                        console.error(`error fetching directions ${result}`)
                    }
                }
            )
        }
    }, [isLoaded, centerPathLat])

    React.useEffect(() => {
        startSimulation()
        calculatePath()

        return () => {
            console.log('CLEAR........')
            interval && window.clearInterval(interval)
        }
    }, [paths])

    const moveObject = () => {
        const distance = getDistance()
        if (!distance) {
            return
        }

        let progress = paths.filter(
            (coordinates) => coordinates.distance < distance
        )

        const nextLine = paths.find(
            (coordinates) => coordinates.distance > distance
        )

        if (!nextLine) {
            setProgress(progress)
            window.clearInterval(interval)
            console.log('Trip Completed!! Thank You !!')
            return // it's the end!
        }
        const lastLine = progress[progress.length - 1]

        const lastLineLatLng = new window.google.maps.LatLng(
            lastLine.lat,
            lastLine.lng
        )

        const nextLineLatLng = new window.google.maps.LatLng(
            nextLine.lat,
            nextLine.lng
        )

        // distance of this line
        const totalDistance = nextLine.distance - lastLine.distance
        const percentage = (distance - lastLine.distance) / totalDistance

        const position = window.google.maps.geometry.spherical.interpolate(
            lastLineLatLng,
            nextLineLatLng,
            percentage
        )

        mapUpdate()
        setProgress(progress.concat(position))
    }

    const mapUpdate = () => {
        const distance = getDistance()
        if (!distance) {
            return
        }

        let progress = paths.filter(
            (coordinates) => coordinates.distance < distance
        )

        const nextLine = paths.find(
            (coordinates) => coordinates.distance > distance
        )

        let point1, point2

        if (nextLine) {
            point1 = progress[progress.length - 1]
            point2 = nextLine
        } else {
            // it's the end, so use the latest 2
            point1 = progress[progress.length - 2]
            point2 = progress[progress.length - 1]
        }

        const point1LatLng = new window.google.maps.LatLng(
            point1.lat,
            point1.lng
        )
        const point2LatLng = new window.google.maps.LatLng(
            point2.lat,
            point2.lng
        )

        const angle = window.google.maps.geometry.spherical.computeHeading(
            point1LatLng,
            point2LatLng
        )
        const actualAngle = angle - 90

        const marker: any = document.querySelector(`[src="${urlIcon}"]`)

        if (marker) {
            // when it hasn't loaded, it's null
            marker.style.transform = `rotate(${actualAngle}deg)`
        }
    }

    const startSimulation = React.useCallback(() => {
        if (interval) {
            window.clearInterval(interval)
        }
        setProgress([])
        initialDate = Date.now()
        interval = window.setInterval(moveObject, 1000)
    }, [interval, initialDate])

    const getDistance = () => {
        // seconds between when the component loaded and now
        const differentInTime = (Date.now() - initialDate) / 1000 // pass to seconds
        return differentInTime * velocity // d = v*t -- thanks Newton!
    }

    const calculatePath = () => {
        paths = paths.map((coordinates, i, array) => {
            if (i === 0) {
                return { ...coordinates, distance: 0 } // it begins here!
            }
            const { lat: lat1, lng: lng1 } = coordinates
            const latLong1 = new window.google.maps.LatLng(lat1, lng1)

            const { lat: lat2, lng: lng2 } = array[0]
            const latLong2 = new window.google.maps.LatLng(lat2, lng2)

            // in meters:
            const distance =
                window.google.maps.geometry.spherical.computeDistanceBetween(
                    latLong1,
                    latLong2
                )

            return { ...coordinates, distance }
        })
    }

    return (
        <>
            {isLoaded && (
                <>
                    <GoogleMap
                        onLoad={(map) => {
                            const bounds = new window.google.maps.LatLngBounds()
                            map.fitBounds(bounds)
                        }}
                        mapContainerStyle={{
                            width: '100%',
                            height: '90vh',
                        }}
                        // center={{ lat: centerPathLat, lng: centerpathLng }}
                        zoom={17}
                    >
                        <Polyline
                            path={paths}
                            options={{
                                strokeColor: '#0088FF',
                                strokeWeight: 6,
                                strokeOpacity: 0.6,
                                visible: true,
                            }}
                        />

                        {stops.map((stop, index) => (
                            <Marker
                                key={index}
                                position={{
                                    lat: stop.lat,
                                    lng: stop.lng,
                                }}
                                onClick={() => alert('aa')}
                                // label={``}
                            />
                        ))}

                        <DirectionsRenderer
                            directions={directions}
                            options={{
                                markerOptions: {
                                    icon: {
                                        url: '',
                                    },
                                },
                            }}
                        />

                        {progress.length > 0 && (
                            <>
                                <Polyline
                                    // path={[...paths, ...stops]}
                                    options={{
                                        strokeColor: 'orange',
                                        strokeWeight: 6,
                                        strokeOpacity: 1,
                                    }}
                                />

                                <Marker
                                    icon={{
                                        url: urlIcon,

                                        anchor: new window.google.maps.Point(
                                            20,
                                            20
                                        ),
                                        scaledSize: new window.google.maps.Size(
                                            50,
                                            50
                                        ),
                                    }}
                                    position={progress[progress.length - 1]}
                                />
                            </>
                        )}
                    </GoogleMap>
                </>
            )}
        </>
    )
}

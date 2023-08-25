import React from 'react'
import { Box, Grid, GridItem, Text, Image, TabPanel, Skeleton, SimpleGrid } from '@chakra-ui/react'
import { Buttons, DeleteConfirm, Icons, Root, TabsComponent } from 'ui'
import { bannerService, usePickImage } from 'hooks'
import { dataListBanner } from '~/navigation'
import BannerAddPages from './banner-add'
import { disclousureStore } from '~/store'
import { useNavigate, useSearchParams } from 'react-router-dom'

const setHeight = () => {
    if (window.screen.availWidth >= 1920) {
        return '77vh'
    }
    if (window.screen.availWidth >= 1535) {
        return '70vh'
    }
    if (window.screen.availWidth >= 1440) {
        return '68vh'
    }
    if (window.screen.availWidth >= 1366) {
        return '68vh'
    }

    return '100%'
}

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListBanner} backUrl={'/'} activeNum={1}>
        {children}
    </Root>
)

const Banners: React.FC<{ type: 'INTERNAL' | 'EXTERNAL' }> = ({ type }) => {
    const t = type === 'INTERNAL' ? 1 : 2
    const [isOpen, setOpen] = React.useState(false)
    const ids = React.useRef<string>('')
    const { selectedFile } = usePickImage()
    const { data, error, isLoading } = bannerService.useGetBanner(t)
    const { remove, create } = bannerService.useBanner()
    const isAdd = disclousureStore((v) => v.isAdd)
    const navigate = useNavigate()

    React.useEffect(() => {
        navigate({ pathname: '/banner', search: `?type=${type}` })
    }, [type])

    React.useEffect(() => {
        if (selectedFile) create.mutate({ file: selectedFile, type: t })
    }, [selectedFile, ids.current])

    if (error) {
        return <Text>{error}</Text>
    }

    if (isLoading) {
        return (
            <SimpleGrid columns={4} gap={4}>
                {[1].map((i) => (
                    <React.Fragment key={i}>
                        <Skeleton width={'full'} height={'250px'} rounded={'md'} />
                        <Skeleton width={'full'} height={'250px'} rounded={'md'} />
                        <Skeleton width={'full'} height={'250px'} rounded={'md'} />
                        <Skeleton width={'full'} height={'250px'} rounded={'md'} />
                    </React.Fragment>
                ))}
            </SimpleGrid>
        )
    }

    const handleDelete = async () => {
        await remove.mutateAsync(ids.current)
        setOpen(false)
    }

    return (
        <>
            {isAdd && <BannerAddPages />}
            <DeleteConfirm
                isLoading={remove.isLoading}
                isOpen={isOpen}
                setOpen={() => setOpen(false)}
                onClose={() => setOpen(false)}
                desc={'Banner'}
                onClick={handleDelete}
            />
            <Box overflow={'auto'} minH={setHeight()} maxH={setHeight()} mt={2}>
                <Grid templateColumns="repeat(4, 1fr)" gap={1} mt={5}>
                    {data?.map((it, id) => (
                        <GridItem
                            key={it.id}
                            p={2}
                            rounded={'xl'}
                            _hover={{
                                background: '#D2D2D2',
                            }}
                        >
                            <Text fontWeight={'semibold'}>Banner {id + 1}</Text>
                            <Image
                                rounded={'xl'}
                                src={it.imageUrl}
                                objectFit={'cover'}
                                width={'full'}
                                height={'250px'}
                                _hover={{
                                    opacity: 0.5,
                                    transition: 'all .2s ease-in',
                                    cursor: 'pointer',
                                }}
                                onClick={() => {
                                    ids.current = `${it.id}`
                                    setOpen(true)
                                }}
                            />
                        </GridItem>
                    ))}
                </Grid>
            </Box>
        </>
    )
}

const BannerPages = () => {
    const TabList = ['INTERNAL', 'PUBLIK']
    const setOpenAdd = disclousureStore((v) => v.setOpenAdd)
    const [query] = useSearchParams()

    const idx = () => {
        if (query.get('type') === 'EXTERNAL') {
            return 1
        }
        return 0
    }

    return (
        <Wrap>
            <Buttons label="Tambah Banner" onClick={() => setOpenAdd(true)} mb={2} leftIcon={<Icons.AddIcons />} />
            <TabsComponent TabList={TabList} defaultIndex={idx()}>
                <TabPanel pl={-10}>
                    <Banners type="INTERNAL" />
                </TabPanel>
                <TabPanel pl={-10}>
                    <Banners type="EXTERNAL" />
                </TabPanel>
            </TabsComponent>
        </Wrap>
    )
}

export default BannerPages

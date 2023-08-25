import React from 'react'
import { Tab, TabList, TabPanels, Tabs } from '@chakra-ui/react'

type TabsCompProps = {
    children: React.ReactNode
    TabList: React.ReactNode[]
    defaultIndex: number
    link?: string
    onClick?: React.MouseEventHandler<HTMLButtonElement> | undefined
    isLazy?: boolean
    onChange?: ((index: number) => void) | undefined
}

export const TabsComponent: React.FC<TabsCompProps> = React.memo((props) => {
    const setIzLazy = React.useMemo(() => {
        if (props.isLazy !== undefined) return props.isLazy
        return true
    }, [props.isLazy])

    return (
        <Tabs
            defaultIndex={props.defaultIndex}
            isLazy={setIzLazy}
            onChange={props.onChange}
        >
            <TabList experimental_spaceX={10} bg="white" mb={'-10px'}>
                {props.TabList.map((it, k) => (
                    <Tab
                        key={k}
                        _selected={{ color: 'red.200' }}
                        width={200}
                        fontSize={'sm'}
                        p={4}
                        w={'fit-content'}
                        fontWeight={'semibold'}
                        onClick={props.onClick}
                    >
                        {it}
                    </Tab>
                ))}
            </TabList>
            <TabPanels>{props.children}</TabPanels>
        </Tabs>
    )
})

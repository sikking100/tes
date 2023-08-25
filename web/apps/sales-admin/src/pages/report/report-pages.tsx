import React from 'react'
import { Buttons, DatePicker, Icons, Modals, Root, Shared, Tables, Types } from 'ui'
import { HStack, Text } from '@chakra-ui/layout'
import { useCSVDownloader } from 'react-papaparse'
import Select, { SingleValue } from 'react-select'
import { Box } from '@chakra-ui/react'
import AsyncSelect from 'react-select/async'
import { categoryService, orderService, store } from 'hooks'
import { Branch, Category, Eroles, Eteam, ReportOrder, ReportPerformance, SelectsTypes } from 'apis'
import { create } from 'zustand'
import { searchsBranch } from '../business/function'

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const dataListOrder: Types.ListSidebarProps[] = [
        {
            id: 1,
            link: '/report',
            title: 'Report',
        },
    ]
    return (
        <Root appName="Sales" items={dataListOrder} backUrl={'/'} activeNum={1}>
            {children}
        </Root>
    )
}

enum TypeReport {
    REPORT_SALES = 1,
    REPORT_CABANG = 2,
}

interface IDateQuery {
    startDate?: string
    endDate?: string
    type?: TypeReport
    branchId?: string
    team?: Eteam
}

interface IReportStore {
    isOpen: boolean
    setOpen: (v: boolean) => void
    setData: (v: IDateQuery) => void
    data?: IDateQuery
}

const reportStore = create<IReportStore>((set, get) => ({
    isOpen: true,
    data: undefined,
    setOpen: (v) => set({ isOpen: v }),
    setData: (v) => {
        set({
            data: {
                ...get().data,
                ...v,
            },
        })
    },
}))

const OrderExportDetail: React.FC = () => {
    const admin = store.useStore((v) => v.admin)
    const [currentDate, setCurrentDate] = React.useState<Date[]>([new Date(), new Date()])
    const setOpen = reportStore((v) => v.setOpen)
    const isOpen = reportStore((v) => v.isOpen)
    const setData = reportStore((v) => v.setData)
    const dataQuery = reportStore((v) => v.data)

    const bySearchBranch = searchsBranch()

    const dataSelects: SelectsTypes[] = [
        {
            value: `${TypeReport.REPORT_SALES}`,
            label: 'REPORT SALES',
        },
        {
            value: `${TypeReport.REPORT_CABANG}`,
            label: 'REPORT CABANG',
        },
    ]

    const setDate = () => {
        const fDate = Shared.tommorowDate(new Date(currentDate[0]).toISOString())
        const lDate = Shared.tommorowDate(new Date(currentDate[1]).toISOString())
        setData({
            startDate: fDate,
            endDate: lDate,
        })
        setOpen(false)
    }

    const onChangeSelectDataBranch = (e: SingleValue<SelectsTypes>) => {
        if (!e) return
        const branch = JSON.parse(e?.value) as Branch
        setData({ branchId: branch.id })
    }

    const onChangeTypeReport = (e: SingleValue<SelectsTypes>) => {
        if (!e) return
        setData({ type: Number(e.value) })
    }

    const onChangeTeam = (e: SingleValue<SelectsTypes>) => {
        if (!e) return
        setData({ team: Number(e.value) })
    }

    return (
        <Modals isOpen={isOpen} setOpen={() => setOpen(false)} scrlBehavior="outside" size="5xl" title="Report">
            <Box experimental_spaceY={3}>
                <Box>
                    <Text fontSize={'sm'} textTransform={'capitalize'} fontWeight={500} pb={1.5}>
                        Pilih Jenis Report
                    </Text>
                    <Select placeholder={'Pilih Jenis Report'} options={dataSelects} onChange={onChangeTypeReport} />
                </Box>

                {dataQuery?.type === TypeReport.REPORT_SALES && (
                    <Box>
                        <Text fontSize={'sm'} textTransform={'capitalize'} fontWeight={500} pb={1.5}>
                            Pilih Tim
                        </Text>
                        <Select
                            placeholder={'Pilih Tim'}
                            options={[
                                {
                                    value: `${Eteam.RETAIL}`,
                                    label: 'Retail',
                                },
                                {
                                    value: `${Eteam.FOOD}`,
                                    label: 'Food Serivce',
                                },
                            ]}
                            onChange={onChangeTeam}
                        />
                    </Box>
                )}

                <Box>
                    <Text fontSize={'sm'} textTransform={'capitalize'} fontWeight={500} pb={1.5}>
                        Pilih Tanggal
                    </Text>
                    <DatePicker callback={(e) => setCurrentDate(e)} />
                </Box>

                {admin?.roles === Eroles.SALES_ADMIN ? (
                    <React.Fragment>
                        <Box>
                            <Text fontSize={'sm'} textTransform={'capitalize'} fontWeight={500} pb={1.5}>
                                Pilih Cabang
                            </Text>
                            <AsyncSelect
                                placeholder={'Pilih Cabang'}
                                defaultOptions
                                loadOptions={bySearchBranch}
                                onChange={onChangeSelectDataBranch}
                            />
                        </Box>
                    </React.Fragment>
                ) : null}

                <HStack>
                    <Buttons label="Tampilkan" w={'150px'} onClick={setDate} />
                    <Buttons bg={'gray.200'} color={'black'} label="Batal" w={'150px'} onClick={() => setOpen(false)} />
                </HStack>
            </Box>
        </Modals>
    )
}

const setQueryExport = () => {
    const admin = store.useStore((v) => v.admin)
    const data = reportStore((v) => v.data)

    return {
        type: data?.type,
        team: data?.team,
        startAt: `${data?.startDate}`,
        endAt: `${data?.endDate}`,
        branchId: admin ? (admin.roles === Eroles.SALES_ADMIN ? data?.branchId : admin.location.id) : undefined,
    }
}

const OrderExportDataPages = () => {
    const dataQuery = reportStore((v) => v.data)
    const setOpen = reportStore((v) => v.setOpen)
    const { data: dataCategory } = categoryService.useGetCategory()

    const { CSVDownloader, Type } = useCSVDownloader()
    const { column: cReport } = columnsReport()
    const { column: csPerformance } = columnsPerformance(dataCategory)
    const { data: reportBranch, isLoading } = orderService.useGetOrderReport({
        query: `${setQueryExport().branchId}`,
        startAt: setQueryExport().startAt,
        endAt: setQueryExport().endAt,
    })
    const { data: performance, isLoading: isLoadingPerformance } = orderService.useGetOrderPerformance({
        query: `${setQueryExport().branchId}`,
        startAt: setQueryExport().startAt,
        endAt: setQueryExport().endAt,
        team: setQueryExport().team as Eteam,
    })

    console.log(setQueryExport())

    const transformDataBranch = reportBranch?.map((v) => ({
        'ID Order': v.orderId,
        'Nama Pelanggan': v.customerName,
        'ID Pelanggan': v.customerId,
        'ID Sales': v.salesId,
        'Nama Sales': v.salesName,
        'Nama Region': v.regionName,
        'Nama Cabang': v.branchName,
        'ID Produk': v.productId,
        'Nama Produk': v.productName,
        Poin: v.productPoint,
        Quantity: v.productQty,
        'Unit Harga': v.productUnitPrice,
        Diskon: v.productDiscount,
        'Total Harga': v.productTotalPrice,
        'Tanggal Dibuat': Shared.FormatDateToString(v.createdAt),
    }))

    const transformDataPerformance = performance?.map((it) => ({
        'ID Region': it.regionId,
        'Nama Region': it.regionName,
        'ID Cabang': it.branchId,
        'Nama Cabang': it.branchName,
        'Nama Kategori': it.categoryName,
        Target: dataCategory?.find((v) => v.id === it.categoryId)?.target || 0,
        Terjual: it.qty,
    }))

    return (
        <Wrap>
            <>
                <OrderExportDetail />
                <CSVDownloader
                    type={Type.Button}
                    filename={`REPORT ${Shared.FormatDateToString(new Date().toISOString())}.csv`}
                    bom={true}
                    data={
                        dataQuery?.type === TypeReport.REPORT_SALES
                            ? transformDataPerformance
                            : dataQuery?.type === TypeReport.REPORT_CABANG
                            ? transformDataBranch
                            : []
                    }
                >
                    <Buttons leftIcon={<Icons.ExportIcons fontSize={22} />} label={'Export'} mb={3} w={'200px'} />
                </CSVDownloader>
                <Buttons
                    label="Report"
                    leftIcon={<Icons.IconFilter fontSize={22} />}
                    mb={3}
                    ml={3}
                    onClick={() => {
                        setOpen(true)
                    }}
                />
                {dataQuery?.type === TypeReport.REPORT_SALES && (
                    <Tables isLoading={isLoadingPerformance} columns={csPerformance} data={!performance ? [] : performance} />
                )}

                {dataQuery?.type === TypeReport.REPORT_CABANG && (
                    <Tables isLoading={isLoading} columns={cReport} data={!reportBranch ? [] : reportBranch} />
                )}

                {!dataQuery?.type && <Tables isLoading={false} columns={csPerformance} data={[]} />}
            </>
        </Wrap>
    )
}

const columnsReport = () => {
    const column: Types.Columns<ReportOrder>[] = [
        {
            header: 'ID Order',
            render: (v) => <Text w={'200px'}>{v.orderId}</Text>,
        },
        {
            header: 'ID Sales',
            render: (v) => <Text w={'200px'}>{v.salesId}</Text>,
        },
        {
            header: 'Nama Sales',
            render: (v) => <Text w={'200px'}>{v.salesName}</Text>,
        },
        {
            header: 'Nama Region',
            render: (v) => <Text w={'200px'}>{v.regionName}</Text>,
        },
        {
            header: 'Nama Cabang',
            render: (v) => <Text w={'200px'}>{v.branchName}</Text>,
        },
        {
            header: 'ID Pelanggan',
            render: (v) => <Text w={'200px'}>{v.customerId}</Text>,
        },
        {
            header: 'Nama Pelanggan',
            render: (v) => <Text w={'200px'}>{v.customerName}</Text>,
        },
        {
            header: 'ID Produk',
            render: (v) => <Text w={'200px'}>{v.productId}</Text>,
        },
        {
            header: 'Nama Produk',
            render: (v) => <Text w={'200px'}>{v.productName}</Text>,
        },
        {
            header: 'Poin',
            render: (v) => <Text w={'100px'}>{v.productPoint}</Text>,
        },
        {
            header: 'Quantity',
            render: (v) => <Text>{v.productQty}</Text>,
        },
        {
            header: <Text textAlign={'right'}>Unit Harga</Text>,
            render: (v) => (
                <Text w={'200px'} textAlign={'right'}>
                    {Shared.formatRupiah(String(v.productUnitPrice))}
                </Text>
            ),
        },
        {
            header: (
                <Text w={'200px'} textAlign={'right'}>
                    Diskon
                </Text>
            ),
            render: (v) => (
                <Text w={'200px'} textAlign={'right'}>
                    {Shared.formatRupiah(`${v.productDiscount}`)}
                </Text>
            ),
        },
        {
            header: (
                <Text w={'200px'} textAlign={'right'}>
                    Total Harga
                </Text>
            ),
            render: (v) => (
                <Text w={'200px'} textAlign={'right'}>
                    {Shared.formatRupiah(`${v.productTotalPrice}`)}
                </Text>
            ),
        },
        {
            header: (
                <Text w={'200px'} textAlign={'right'}>
                    PPN
                </Text>
            ),
            render: (v) => (
                <Text w={'200px'} textAlign={'right'}>
                    {Shared.formatRupiah(`${Math.ceil((v.productUnitPrice - v.tax) * v.productQty)}`)}
                </Text>
            ),
        },
    ]

    return {
        column,
    }
}

const columnsPerformance = (dCategory?: Category[]) => {
    const column: Types.Columns<ReportPerformance>[] = [
        {
            header: 'ID Region',
            render: (v) => <Text w={'200px'}>{v.regionId}</Text>,
        },
        {
            header: 'Nama Region',
            render: (v) => <Text w={'200px'}>{v.regionName}</Text>,
        },
        {
            header: 'ID Cabang',
            render: (v) => <Text w={'200px'}>{v.branchId}</Text>,
        },
        {
            header: 'Nama Cabang',
            render: (v) => <Text w={'200px'}>{v.branchName}</Text>,
        },
        {
            header: 'Nama Kategori',
            render: (v) => <Text w={'200px'}>{v.categoryName}</Text>,
        },
        {
            header: 'Target',
            render: (v) => {
                const find = dCategory?.find((it) => it.id === v.categoryId)
                return <Text w={'200px'}>{find?.target || 0}</Text>
            },
        },
        {
            header: 'Terjual',
            render: (v) => <Text w={'200px'}>{v.qty}</Text>,
        },
    ]

    return {
        column,
    }
}
export default OrderExportDataPages

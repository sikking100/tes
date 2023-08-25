import React from 'react'
import { Table, Tbody, Td, Th, Thead, Tr, TableContainer, Box, HStack, Text, Divider } from '@chakra-ui/react'
import { Buttons, Root, Types, useToast } from 'ui'
import { useNavigate } from 'react-router-dom'
import { Eroles, Location, getBranchApiInfo, getEmployeeApiInfo, getRegionApiInfo } from 'apis'
import { ETeam } from 'apis/services/product/types'

export interface UserRequest {
    id: string
    nama: string
    nomorHp: string
    email: string
    tim: string
    role: string
    locationId: string
}

interface ErrorTypes {
    id: string
    error: string
}

const dataListAccount: Types.ListSidebarProps[] = [
    {
        id: 1,
        link: '/import/account',
        title: 'Akun Import',
    },
]

const Wrap: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Root appName="System" items={dataListAccount} backUrl={'/account'} activeNum={1}>
        {children}
    </Root>
)

const AccountImportPreviewPages = () => {
    const navigate = useNavigate()
    const [isLoading, setLoading] = React.useState(false)
    const [data, setData] = React.useState<UserRequest[]>([])
    const toast = useToast()
    const [errors, setErrors] = React.useState<ErrorTypes[]>([])
    const [dataFailed, setDataFailed] = React.useState<UserRequest[]>([])

    const headerRow: string[] = ['ID', 'Nama', 'Nomor HP', 'Email', 'Tim', 'Role', 'Location']

    React.useEffect(() => {
        const dataLocal = localStorage.getItem('user-import')
        const dataParse = JSON.parse(String(dataLocal)) as UserRequest[]
        const data = dataParse.splice(0, dataParse.length - 1)
        setData(data)
    }, [])

    const handleSubmit = async () => {
        const errData: ErrorTypes[] = []
        const dataFailed: UserRequest[] = []
        setLoading(true)
        let location: Location | null = null

        for await (const i of data) {
            const phones = i.nomorHp.startsWith('0') ? i.nomorHp.replace('0', '+62') : i.nomorHp
            const setRoles = () => {
                const rolesAdmin = i.role.toLowerCase()
                if (rolesAdmin === 'system admin') return Eroles.SYSTEM_ADMIN
                if (rolesAdmin === 'finance admin') return Eroles.FINANCE_ADMIN
                if (rolesAdmin === 'sales admin') return Eroles.SALES_ADMIN
                if (rolesAdmin === 'branch admin') return Eroles.BRANCH_ADMIN
                if (rolesAdmin === 'general manager') return Eroles.GENERAL_MANAGER
                if (rolesAdmin === 'nasional sales manager') return Eroles.NASIONAL_SALES_MANAGER
                if (rolesAdmin === 'regional manager') return Eroles.REGIONAL_MANAGER
                if (rolesAdmin === 'direktur') return Eroles.DIREKTUR
                return 0
            }
            const teams = i.tim.toLowerCase() === 'food service' ? ETeam.FOOD : i.tim.toLowerCase() === 'retail' ? ETeam.RETAIL : 0

            try {
                if (setRoles() === Eroles.BRANCH_ADMIN) {
                    const branch = await getBranchApiInfo().findById(i.locationId)
                    location = {
                        id: branch.id,
                        name: branch.name,
                        type: 2,
                    }
                }
                if (setRoles() === Eroles.REGIONAL_MANAGER) {
                    const region = await getRegionApiInfo().findById(i.locationId)
                    location = {
                        id: region.id,
                        name: region.name,
                        type: 1,
                    }
                }

                await getEmployeeApiInfo().create({
                    id: i.id,
                    email: i.email,
                    location,
                    name: i.nama,
                    phone: phones,
                    roles: setRoles(),
                    team: teams,
                })
            } catch (error) {
                const err = error as Error
                errData.push({ id: i.id, error: `${err.message}` })
                dataFailed.push(i)
                continue
            }
        }

        setLoading(false)
        if (errData.length > 0) {
            toast({
                status: 'error',
                description: `${errData.length} akun gagal diimport, ${errData[0].error}`,
            })
            setDataFailed(dataFailed)
            setErrors(errData)
        }
        if (errData.length < 1) {
            toast({
                status: 'success',
                description: 'Import akun berhasil',
            })
            localStorage.removeItem('user-import')
            navigate('/account', { replace: true })
        }
    }

    return (
        <Wrap>
            <HStack pb={3}>
                <Buttons label="Simpan" onClick={handleSubmit} isLoading={isLoading} />
            </HStack>
            {errors.length > 0 && (
                <Box my={'10px'}>
                    <Text fontSize={'md'} fontWeight={'semibold'}>
                        List User Gagal Di Import
                    </Text>
                    <Divider />
                </Box>
            )}
            <Box overflow={'auto'}>
                <TableContainer>
                    <Table size="md" bg="white" rounded={'md'}>
                        <Thead height={'40px !important'}>
                            <Tr>
                                {headerRow.map((v) => {
                                    return (
                                        <Th key={v} fontSize={'14px !important'}>
                                            {v}
                                        </Th>
                                    )
                                })}
                            </Tr>
                        </Thead>
                        <Tbody>
                            {errors.length > 0 && (
                                <>
                                    {dataFailed.map((i, k) => {
                                        return (
                                            <Tr key={k}>
                                                <Td>{i.id}</Td>
                                                <Td>{i.nama}</Td>
                                                <Td>{i.nomorHp}</Td>
                                                <Td>{i.email}</Td>
                                                <Td>{i.tim}</Td>
                                                <Td>{i.role}</Td>
                                                <Td>{i.locationId}</Td>
                                            </Tr>
                                        )
                                    })}
                                </>
                            )}
                            {errors.length < 1 && (
                                <>
                                    {data.map((i, k) => {
                                        return (
                                            <Tr key={k}>
                                                <Td>{i.id}</Td>
                                                <Td>{i.nama}</Td>
                                                <Td>{i.nomorHp}</Td>
                                                <Td>{i.email}</Td>
                                                <Td>{i.tim}</Td>
                                                <Td>{i.role}</Td>
                                                <Td>{i.locationId}</Td>
                                            </Tr>
                                        )
                                    })}
                                </>
                            )}
                        </Tbody>
                    </Table>
                </TableContainer>
            </Box>
        </Wrap>
    )
}

export default AccountImportPreviewPages

import { HStack, Text } from '@chakra-ui/react'
import React from 'react'
import { CheckIcon } from '@chakra-ui/icons'
import { Branch, getBranchApiInfo, Warehouse } from 'apis'
import { Modals, Tables, Types } from 'ui'

interface Props {
    isOpen: boolean
    setOpen: (isOpen: boolean) => void
    branch: Branch
}

const ModalDetailWarehouse: React.FC<Props> = ({ isOpen, setOpen, branch }) => {
    if (!isOpen) return null
    const [data, setData] = React.useState<Warehouse[]>([])
    const [isLoading, setLoading] = React.useState(true)
    // const nWarehouse = getBranchApiInfo().getWarehouseByBranch(branch.id)
    const { column } = columns()

    React.useEffect(() => {
        getBranchApiInfo()
            .getWarehouseByBranch(branch.id)
            .then((res) => {
                setData(res)
            })
            .finally(() => setLoading(false))
    }, [branch])

    return (
        <Modals isOpen={isOpen} setOpen={() => setOpen(false)} size="4xl" title={`${branch.name}`}>
            <Tables columns={column} data={data} pageH="400px" isLoading={isLoading} />
        </Modals>
    )
}

const columns = () => {
    const column: Types.Columns<Warehouse>[] = [
        {
            header: 'Nama',
            render: (v) => (
                <HStack>
                    <Text>{v.name}</Text>
                    {v.isDefault && <CheckIcon color="green.500" />}
                </HStack>
            ),
        },
        {
            header: 'Alamat',
            render: (v) => <Text>{v.address.name}</Text>,
        },
        {
            header: 'Nomor HP',
            render: (v) => <Text>{v.phone}</Text>,
        },
    ]

    return { column }
}

export default ModalDetailWarehouse

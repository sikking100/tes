import { Box, Text, VStack, VisuallyHidden } from '@chakra-ui/react'
import React from 'react'
import { ButtonForm, FormControlNumbers, FormSelects, Modals, useToast } from 'ui'
import { store, productService, branchService } from 'hooks'
import type { ProductTypes, SelectsTypes } from 'apis'
import { SubmitHandler, useForm } from 'react-hook-form'

type QtyReqUpdate = ProductTypes.CreateTransferQty & {
    product: ProductTypes.Product
    newWarehouseFrom: SelectsTypes
    newWrehouseTo: SelectsTypes
}

interface ModalMoveQty {
    isOpen: boolean
    setOpen: (isOpen: boolean) => void
    productId: string
}

const MoveQty: React.FC<ModalMoveQty> = ({ isOpen, setOpen, productId }) => {
    const admin = store.useStore((i) => i.admin)
    const toast = useToast()
    const { transferQty } = productService.useProdcutBranch()
    const { data: dataProduct } = productService.useGetProductBranchById(productId)
    const { data: dataBranch } = branchService.useGetBranchId(`${admin?.location?.id}`)

    const {
        handleSubmit,
        register,
        watch,
        getValues,
        control,
        formState: { errors },
    } = useForm<QtyReqUpdate>({})

    const onSubmit: SubmitHandler<QtyReqUpdate> = async (data) => {
        if (!admin) return
        const qty = Number(data.qty)

        if (qty > onCheckQty().qty) {
            toast({
                status: 'error',
                description: 'Stok tidak mencukupi',
            })
            return
        }

        const ReqData: ProductTypes.CreateTransferQty = {
            creator: { ...admin },
            fromWarehouseId: data.newWarehouseFrom.value,
            fromWarehouseName: data.newWarehouseFrom.label,
            productId: productId,
            qty,
            toWarehouseId: data.newWrehouseTo.value,
            toWarehouseName: data.newWrehouseTo.label,
        }
        await transferQty.mutateAsync(ReqData)
        setOpen(false)
    }

    const optionsToWarehouse = () => {
        const getFromWarehouse = getValues('newWarehouseFrom.value')
        const filter = dataBranch?.warehouse.filter((v) => v.id !== getFromWarehouse)
        const mWarehouse = filter?.map((v) => ({
            label: v.name,
            value: v.id,
        }))
        return mWarehouse
    }

    const onCheckQty = () => {
        let qty = 0
        let name = ''
        const getFromWarehouse = getValues('newWarehouseFrom.value')
        const findProduct = dataProduct?.warehouse.find((v) => v.id === getFromWarehouse)
        if (findProduct) {
            qty = findProduct.qty
            name = findProduct.name
        }
        return {
            qty,
            name,
        }
    }

    return (
        <Modals
            isOpen={isOpen}
            setOpen={() => {
                setOpen(false)
            }}
            title={'Transfer Stok'}
            size="4xl"
            scrlBehavior="outside"
        >
            <form onSubmit={handleSubmit(onSubmit)}>
                <>
                    <VStack w={'full'} align={'stretch'} spacing={3}>
                        <FormSelects
                            control={control}
                            label="newWarehouseFrom"
                            options={dataProduct?.warehouse.map((v) => {
                                return {
                                    value: v.id,
                                    label: `${v.name}`,
                                }
                            })}
                            placeholder="Cari"
                            title={'Asal Gudang'}
                            required={'From Gudang tidak boleh kosong'}
                            errors={errors.newWarehouseFrom?.message}
                        />
                        {watch('newWarehouseFrom') && (
                            <Text mt={'4px !important'} ml={'3px !important'} fontWeight={'500'} fontSize={'sm'}>
                                STOK {onCheckQty().qty}
                            </Text>
                        )}
                        <VisuallyHidden>{JSON.stringify(watch('newWarehouseFrom.value'))}</VisuallyHidden>
                        <Box>
                            {watch('newWarehouseFrom') ? (
                                <FormSelects
                                    control={control}
                                    label="newWrehouseTo"
                                    options={optionsToWarehouse()}
                                    placeholder="Cari "
                                    title={'Gudang Tujuan'}
                                    required={'Gudang Tujuan tidak boleh kosong'}
                                    errors={errors.newWarehouseFrom?.message}
                                />
                            ) : null}
                        </Box>
                        <FormControlNumbers title="Jumlah" label={'qty'} register={register} control={control} />
                    </VStack>
                </>
                <ButtonForm isLoading={transferQty.isLoading} label="Transfer" onClose={() => setOpen(false)} />
            </form>
        </Modals>
    )
}

export default MoveQty

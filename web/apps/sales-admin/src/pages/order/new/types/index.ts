import { Control, FormState, UseFormGetValues, UseFormRegister, UseFormSetValue } from 'react-hook-form'
import { Address, CreateOrder, Customers, SelectsTypes, ProductTypes } from 'apis'
import { CreateProductOrder } from '~/../../../packages/apis/services/order/order'

export interface IReqOrderReq extends CreateOrder {
    shipping_: SelectsTypes
    business_: SelectsTypes
    code_: SelectsTypes
    branch_: SelectsTypes
}

export interface RenderBusinessProps {
    setValue: UseFormSetValue<IReqOrderReq>
    getValues: UseFormGetValues<IReqOrderReq>
    formState: FormState<IReqOrderReq>
    control: Control<IReqOrderReq, any>
}

export interface SummaryProps {
    setValue: UseFormSetValue<IReqOrderReq>
    getValues: UseFormGetValues<IReqOrderReq>
    register: UseFormRegister<IReqOrderReq>
    onPay: () => void
    control: Control<IReqOrderReq, any>
}

export type IOrderC = 'REORDER' | 'ORDER'


interface AddsDiscount {
    [key: string]: number
}

export interface IState {
    customers?: Customers
    address?: Address[]
    addressShipp?: Address
    totalPrice?: number
    productCheckout?: CreateProductOrder[]
    additionalDiscount?: number
    addDiscount?: AddsDiscount
    ongkir?: number
    isLoadingCreate?: boolean
}
export interface FilterProps {
    isOpen: boolean
    onOpen: React.Dispatch<React.SetStateAction<boolean>>
    onSetQuerys: (r: Omit<ProductTypes.ReqProductFind, 'page' | 'limit'>) => void
}

import create, { StateCreator } from 'zustand'
import { devtools } from 'zustand/middleware'
import { Product } from 'apis/services/product/types'

type StateProdcut = {} & Product

interface ChartState {
    product: StateProdcut[]
    setProduct: (by: StateProdcut) => void
    setQty(id: string, qty: number): void
}

const useChartSlice: StateCreator<ChartState> = (set, get) => ({
    product: [],
    setProduct: async (by) => {
        const current = get().product
        set({ product: [...current, by] })
    },
    setQty: (id, qty) => {
        const current = get().product
        const index = current.findIndex((i) => i.id === id)
        const product = [...current]
        product[index] = { ...product[index] }
        set({ product })
    },
})

export const useStore = create<ChartState>()(
    devtools((...a) => ({
        ...useChartSlice(...a),
    }))
)

interface BStore {
    isOpenDelete: boolean
    isOpenEdit: boolean
    isAdd: boolean
    setIsOpenDeelete: (v: boolean) => void
    setIsOpenEdit: (v: boolean) => void
    setOpenAdd: (v: boolean) => void
}

export const disclousureStore = create<BStore>((set) => ({
    isOpenDelete: false,
    isOpenEdit: false,
    isAdd: false,
    setOpenAdd: (v) => set({ isAdd: v }),
    setIsOpenDeelete: (v) => set({ isOpenDelete: v }),
    setIsOpenEdit: (v) => set({ isOpenEdit: v }),
}))
import { create, StateCreator } from 'zustand'
import { devtools } from 'zustand/middleware'

interface IStepsState {
    step?: number
    disableNext?: boolean
    disablePrev?: boolean
    setDisabelNext: (by: boolean) => void
    setDisabelPrev: (by: boolean) => void
}

// interface ChartState {
//   product: StateProdcut[]
//   setProduct: (by: StateProdcut) => void
//   setQty(id: string, qty: number): void
// }

// const useChartSlice: StateCreator<ChartState> = (set, get) => ({
//   product: [],
//   setProduct: async (by) => {
//     const current = get().product
//     set({ product: [...current, by] })
//   },
//   setQty: (id, qty) => {
//     const current = get().product
//     const index = current.findIndex((i) => i.id === id)
//     const product = [...current]
//     product[index] = { ...product[index] }
//     set({ product })
//   },
// })

const useStepsCtx: StateCreator<IStepsState> = (set) => ({
    step: 0,
    disableNext: true,
    disablePrev: true,
    setDisabelNext: (by) => set({ disableNext: by }),
    setDisabelPrev: (by) => set({ disablePrev: by }),
})

export const useStoreSteps = create<IStepsState>()(
    devtools((...a) => ({
        ...useStepsCtx(...a),
    }))
)

interface BStore {
    isOpenDelete: boolean
    isOpenEdit: boolean
    isAdd: boolean
    setIsOpenDelete: (v: boolean) => void
    setIsOpenEdit: (v: boolean) => void
    setOpenAdd: (v: boolean) => void
}

export const disclousureStore = create<BStore>((set) => ({
    isOpenDelete: false,
    isOpenEdit: false,
    isAdd: false,
    setOpenAdd: (v) => set({ isAdd: v }),
    setIsOpenDelete: (v) => set({ isOpenDelete: v }),
    setIsOpenEdit: (v) => {
        set({ isOpenEdit: v })
    },
}))

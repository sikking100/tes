import create from 'zustand'

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
    setIsOpenEdit: (v) => set({ isOpenEdit: v }),
}))

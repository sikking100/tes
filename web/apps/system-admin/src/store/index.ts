import { create } from 'zustand'

interface BStore {
    isOpenDelete: boolean
    isOpenEdit: boolean
    isAdd: boolean
    isPrompt: boolean
    setIsOpenDeelete: (v: boolean) => void
    setIsOpenEdit: (v: boolean) => void
    setOpenAdd: (v: boolean) => void
    setPrompt: (v: boolean) => void
}

export const disclousureStore = create<BStore>((set) => ({
    isOpenDelete: false,
    isOpenEdit: false,
    isAdd: false,
    isPrompt: false,
    setPrompt: (v) => set({ isPrompt: v }),
    setOpenAdd: (v) => set({ isAdd: v }),
    setIsOpenDeelete: (v) => set({ isOpenDelete: v }),
    setIsOpenEdit: (v) => set({ isOpenEdit: v }),
}))

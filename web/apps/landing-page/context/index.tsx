import { createContext, useContext, useState, useMemo } from 'react'

interface ProviderProps {
    children: React.ReactNode
}

interface ModalProps {
    type: 'customer' | 'distributor' | ''
    isOpen: boolean
}

export interface ContextProps {
    activeNav: number
    modal: ModalProps
    setModal(props: ModalProps): void
    setActivenav(it: number): void
}

/**
 * Set Default Value
 */

const contextDefaultValue: ContextProps = {
    activeNav: 1,
    setModal: () => {},
    modal: {
        isOpen: false,
        type: 'customer',
    },
    setActivenav() {
        undefined
    },
}

/**
 * Create Context API
 */

const ThemeContext = createContext<ContextProps>(contextDefaultValue)

const ctxProvider = (): ContextProps => {
    return useContext(ThemeContext)
}

const Provider: React.FC<ProviderProps> = ({ children }: ProviderProps) => {
    const [activeNav, setActivenav] = useState<number>(1)
    const [modal, setModal] = useState<ModalProps>({
        isOpen: false,
        type: 'customer',
    })

    const value = useMemo(
        () => ({ activeNav, setActivenav, modal, setModal }),
        [activeNav, modal]
    )

    return (
        <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
    )
}

export { ctxProvider }

export default Provider

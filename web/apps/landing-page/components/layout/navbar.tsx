import React from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/router'
import Modal from 'react-modal'
// import { SunIcon } from '@heroicons/react/24/outline'

//'Beranda', 'Layanan', 'Tentang Kami', 'Bantuan'

const linkNavigate = [
    {
        label: 'Beranda',
        path: '/',
    },
    {
        label: 'Layanan',
        path: '/service',
    },
    {
        label: 'Tentang Kami',
        path: '/about',
    },
    {
        label: 'Bantuan',
        path: '/help',
    },
]

const NavbarMobile = () => {
    return <div></div>
}

const Navbar = () => {
    const router = useRouter()
    const [isOpen, setOpen] = React.useState(false)

    React.useEffect(() => {
        setOpen(false)
    }, [router.pathname])

    const closeModal = () => {
        setOpen(!isOpen)
    }

    return (
        <nav className="bg-white px-2 sm:px-4 py-2.5 dark:bg-gray-900 fixed w-full z-20 top-0 left-0 border-b border-gray-200 dark:border-gray-600">
            <div className="container flex flex-wrap items-center justify-between mx-auto">
                <div className="items-center">
                    <Image
                        src="/assets/dairyfood_logo.svg"
                        className="object-fill"
                        width={150}
                        height={100}
                        quality={100}
                        alt="Dairy Food Logo"
                    />
                </div>
                <>
                    <button
                        data-collapse-toggle="navbar-sticky"
                        type="button"
                        className="inline-flex items-center p-2 text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
                        aria-controls="navbar-sticky"
                        aria-expanded="false"
                        onClick={() => setOpen(true)}
                    >
                        <span className="sr-only">Open main menu</span>
                        <svg
                            className="w-6 h-6"
                            aria-hidden="true"
                            fill="currentColor"
                            viewBox="0 0 20 20"
                            xmlns="http://www.w3.org/2000/svg"
                        >
                            <path
                                fill-rule="evenodd"
                                d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z"
                                clip-rule="evenodd"
                            ></path>
                        </svg>
                    </button>
                </>
                <div
                    className="items-center justify-between hidden w-full md:flex md:w-auto md:order-1"
                    id="navbar-sticky"
                >
                    <ul className="flex flex-col p-4 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
                        {linkNavigate.map((i) => (
                            <li key={i.path}>
                                <Link
                                    href={i.path}
                                    className={`block py-2 text-[17px] font-semibold pl-3 pr-4 rounded md:bg-transparent  md:p-0 dark:text-white ${
                                        router.pathname === i.path
                                            ? 'text-red-600'
                                            : 'text-gray-600'
                                    }`}
                                    aria-current="page"
                                    passHref
                                >
                                    {i.label}
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>
            </div>
            <Modal
                isOpen={isOpen}
                onRequestClose={closeModal}
                contentLabel="Example Modal"
                style={{
                    content: {
                        marginTop: '50px',
                    },
                }}
            >
                <div>
                    <ul className="flex flex-col p-4 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:flex-row md:space-x-8 md:mt-0 md:text-sm md:font-medium md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700 space-y-5">
                        {linkNavigate.map((i) => (
                            <li key={i.path}>
                                <Link
                                    href={i.path}
                                    className={`block py-2 text-[20px] font-semibold pl-3 pr-4 rounded md:bg-transparent  md:p-0 dark:text-white ${
                                        router.pathname === i.path
                                            ? 'text-red-600'
                                            : 'text-gray-600'
                                    }`}
                                    aria-current="page"
                                    passHref
                                >
                                    {i.label}
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>
            </Modal>
        </nav>
    )
}

export default Navbar

import { NextSeo } from 'next-seo'
import React, { Fragment } from 'react'
import { toast } from 'react-toastify'
import { Dialog, Transition } from '@headlessui/react'

const ModalConfirm: React.FC<{
    isOpen: boolean
    setOpen: (v: boolean) => void
    onSubmits: (v: any) => void
}> = ({ isOpen, setOpen, onSubmits }) => {
    const closeModal = () => setOpen(false)

    return (
        <Transition appear show={isOpen} as={Fragment}>
            <Dialog as="div" className="relative z-100" onClose={closeModal}>
                <Transition.Child
                    as={Fragment}
                    enter="ease-out duration-300"
                    enterFrom="opacity-0"
                    enterTo="opacity-100"
                    leave="ease-in duration-200"
                    leaveFrom="opacity-100"
                    leaveTo="opacity-0"
                >
                    <div className="fixed inset-0 bg-black bg-opacity-25" />
                </Transition.Child>

                <div className="fixed inset-0 overflow-y-auto">
                    <div className="flex min-h-full items-center justify-center p-4 text-center">
                        <Transition.Child
                            as={Fragment}
                            enter="ease-out duration-300"
                            enterFrom="opacity-0 scale-95"
                            enterTo="opacity-100 scale-100"
                            leave="ease-in duration-200"
                            leaveFrom="opacity-100 scale-100"
                            leaveTo="opacity-0 scale-95"
                        >
                            <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
                                <Dialog.Title
                                    as="h3"
                                    className="text-lg font-medium leading-6 text-gray-900"
                                >
                                    Warning
                                </Dialog.Title>
                                <div className="mt-2">
                                    <p className="text-sm text-gray-500">
                                        Are you sure you want to remove your
                                        account? All of your data will be erased
                                    </p>
                                </div>

                                <div className="mt-4">
                                    <button
                                        type="button"
                                        onClick={onSubmits}
                                        className="focus:outline-none w-[8rem] text-red-800  bg-red-200 hover:bg-red-300 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2"
                                    >
                                        Yes
                                    </button>

                                    <button
                                        type="button"
                                        className="inline-flex w-[8rem] justify-center rounded-md border border-transparent bg-blue-100 px-4 py-2 text-sm font-medium text-blue-900 hover:bg-blue-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2"
                                        onClick={closeModal}
                                    >
                                        No
                                    </button>
                                </div>
                            </Dialog.Panel>
                        </Transition.Child>
                    </div>
                </div>
            </Dialog>
        </Transition>
    )
}

const FormPages = () => {
    const [isOpen, setOpen] = React.useState(false)
    const ref = React.useRef<any>(null)

    const onSubmit = (e: any) => {
        e.preventDefault()
        setOpen(true)
    }

    const onSubmits = (e: any) => {
        toast.success(
            'Your account will be deleted by admin within 1 x 24 hours'
        )
        setOpen(false)
        ref.current.reset()
    }

    return (
        <div className="h-screen lg:pt-[5rem] px-5">
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home Contact Dairyfood Internusa"
            />

            {isOpen && (
                <ModalConfirm
                    isOpen={isOpen}
                    setOpen={setOpen}
                    onSubmits={onSubmits}
                />
            )}

            <p className="font-bold text-2xl text-center my-5">
                Account Removal
            </p>

            <form className="space-y-8" onSubmit={onSubmit} ref={ref}>
                <div className="w-full ">
                    <label
                        htmlFor="email"
                        className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                    >
                        Your Name*
                    </label>
                    <div className="grid grid-cols-2 space-x-3 w-full">
                        <div>
                            <input
                                id="name"
                                className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                                placeholder="Name"
                                required
                            />
                        </div>
                        <div>
                            <input
                                id="name"
                                className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                                placeholder="Surename"
                                required
                            />
                        </div>
                    </div>
                </div>
                {/*  */}
                <div className="w-full mt-4">
                    <label
                        htmlFor="email"
                        className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                    >
                        Your email address*
                    </label>
                    <p className="text-gray-700 italic text-xs mb-3">
                        Please enter your registered email address.
                    </p>
                    <div className="relative w-full">
                        <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                            <svg
                                xmlns="http://www.w3.org/2000/svg"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke-width="1.5"
                                stroke="currentColor"
                                className="w-6 h-6"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
                                />
                            </svg>
                        </div>
                        <input
                            type="email"
                            id="simple-search"
                            className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                            required
                        />
                    </div>
                </div>

                {/*  */}
                <div className="w-full my-4">
                    <label
                        htmlFor="phone"
                        className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                    >
                        Your phone number
                    </label>
                    <div className="flex space-x-3 w-full">
                        <div className="w-[10rem] lg:w-[20rem]">
                            <div>
                                <input
                                    id="phone"
                                    type="number"
                                    className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                                    placeholder="Country Code"
                                    required
                                />
                            </div>
                        </div>
                        <div className="w-[10rem] lg:w-[20rem]">
                            <div>
                                <input
                                    id="phone"
                                    type="number"
                                    className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                                    placeholder="Area Code"
                                    required
                                />
                            </div>
                        </div>
                        <div className="relative w-full">
                            <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                    stroke-width="1.5"
                                    stroke="currentColor"
                                    className="w-6 h-6"
                                >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 002.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 01-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 00-1.091-.852H4.5A2.25 2.25 0 002.25 4.5v2.25z"
                                    />
                                </svg>
                            </div>
                            <input
                                type="number"
                                id="phone"
                                className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full pl-10 p-2.5  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                                required
                            />
                        </div>
                    </div>
                </div>
                {/*  */}

                <div>
                    <label
                        htmlFor="message"
                        className="block mb-2 text-sm font-medium text-gray-900 dark:text-white"
                    >
                        Your reason to remove account*
                    </label>
                    <textarea
                        required
                        id="message"
                        rows={4}
                        className="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                        placeholder="Write your message here..."
                    ></textarea>
                </div>

                <button
                    type="submit"
                    className="text-white bg-red-500 hover:bg-red-800 focus:ring-4 focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2 dark:bg-red-600 dark:hover:bg-red-500 focus:outline-none dark:focus:ring-red-800"
                >
                    Submit
                </button>
            </form>
        </div>
    )
}

export default FormPages

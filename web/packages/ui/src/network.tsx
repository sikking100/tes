import React from 'react'
import { toast } from 'react-toastify'

export const Network = () => {
    const [online, isOnline] = React.useState(navigator.onLine)

    const setOnline = () => {
        console.log('Network online!')
        toast('Your Network Back To online', {
            position: 'top-right',
            autoClose: 5000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: 'dark',
        })
        isOnline(true)
    }
    const setOffline = () => {
        console.log('Network offline!')
        toast('Your Network Back offline', {
            position: 'top-right',
            autoClose: 5000,
            hideProgressBar: false,
            closeOnClick: true,
            pauseOnHover: true,
            draggable: true,
            progress: undefined,
            theme: 'dark',
        })
        isOnline(false)
    }

    React.useEffect(() => {
        window.addEventListener('offline', setOffline)
        window.addEventListener('online', setOnline)

        return () => {
            window.removeEventListener('offline', setOffline)
            window.removeEventListener('online', setOnline)
        }
    }, [])

    return <></>
}

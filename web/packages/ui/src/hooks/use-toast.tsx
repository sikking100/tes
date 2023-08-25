import { UseToastOptions } from '@chakra-ui/toast'
import { IStatus, Toast as Toasts } from '../alert'
import { toast } from 'react-toastify'

export const useToast = () => {
    const showToast = ({ description, status, title }: UseToastOptions) => {
        return toast(
            <Toasts
                description={description}
                status={status as IStatus}
                title={title}
            />
        )
    }

    return showToast
}

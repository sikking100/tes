import { useToast } from '../utils/toast'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { getLoginApiInfo, ReqLogin, ReqLoginVerify } from 'apis'
import { asyncHandler } from '../utils/async'
import { useAlert } from '../utils/on-alert'

const key = 'auth'

export const useLogin = () => {
  const queryClient = useQueryClient()
  const toast = useToast()
  const toasts = useAlert({ key, queryClient, toast })

  const login = useMutation<string, Error, ReqLogin>(
    asyncHandler(async (data) => {
      const fcm = data.fcmToken || localStorage.getItem('fcm')
      const res = await getLoginApiInfo().login({
        ...data,
        fcmToken: fcm || '-',
      })
      localStorage.setItem('id-otp', res)
      return res
    }),
    toasts({
      status: 'success',
      title: 'Login',
      description: 'Kode OTP terkirim',
    }),
  )

  const loginVerify = useMutation<void, Error, ReqLoginVerify>(
    asyncHandler(async (data) => {
      const id = localStorage.getItem('id-otp')
      const res = await getLoginApiInfo().loginVerify({
        ...data,
        id: String(id),
      })
      return res
    }),
    toasts({
      status: 'success',
      title: 'Verify OTP',
      description: 'Login berhasil',
    }),
  )

  return {
    login,
    loginVerify,
  }
}

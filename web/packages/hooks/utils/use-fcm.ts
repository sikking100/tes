import { getTokensFcm } from 'apis'

export const SetFcm = async () => {
  return new Promise<string>((res) => {
    Notification.requestPermission().then(async function (permission) {
      if (permission === 'granted') {
        const fcm = await getTokensFcm()
        res(fcm)
      } else {
        res('-')
      }
    })
  })
}

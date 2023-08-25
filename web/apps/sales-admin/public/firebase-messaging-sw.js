importScripts('https://www.gstatic.com/firebasejs/9.12.1/firebase-app-compat.js')
importScripts('https://www.gstatic.com/firebasejs/9.12.1/firebase-messaging-compat.js')

const development = {
  apiKey: 'AIzaSyC-Uji8Ri4-nX59yTWwPOsHMmCRCKgurfo',
  authDomain: 'dairy-food-development.firebaseapp.com',
  projectId: 'dairy-food-development',
  storageBucket: 'dairy-food-development.appspot.com',
  messagingSenderId: '729132625350',
  appId: '1:729132625350:web:f69dc19808f32a291096c7',
  measurementId: 'G-44YTPRVP72',
}

firebase.initializeApp(development)

const messaging = firebase.messaging()

messaging.onBackgroundMessage(function (payload) {
  console.log('Received background message ', payload)

  const notificationTitle = payload.notification.title
  const notificationOptions = {
    body: payload.notification.body,
  }

  self.registration.showNotification(notificationTitle, notificationOptions)
})

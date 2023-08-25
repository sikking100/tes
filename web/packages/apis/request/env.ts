const development = {
  apiKey: 'AIzaSyC-Uji8Ri4-nX59yTWwPOsHMmCRCKgurfo',
  authDomain: 'dairy-food-development.firebaseapp.com',
  projectId: 'dairy-food-development',
  storageBucket: 'dairy-food-development.appspot.com',
  messagingSenderId: '729132625350',
  appId: '1:729132625350:web:f69dc19808f32a291096c7',
  measurementId: 'G-44YTPRVP72',
}

const production = {
  apiKey: 'AIzaSyC-Uji8Ri4-nX59yTWwPOsHMmCRCKgurfo',
  authDomain: 'dairy-food-development.firebaseapp.com',
  projectId: 'dairy-food-development',
  storageBucket: 'dairy-food-development.appspot.com',
  messagingSenderId: '729132625350',
  appId: '1:729132625350:web:f69dc19808f32a291096c7',
  measurementId: 'G-44YTPRVP72',
}

const vapidKeyDev =
  'BHTiCPjNz5FFKdYD8yi4yKa1jVVw0RzwlP4e0H4G-CnuKvHTKSO1v8n74El5SctWWH5PnS6RYc2k9ORuIz78WCk'

const vapidKeyProd =
  'BHTiCPjNz5FFKdYD8yi4yKa1jVVw0RzwlP4e0H4G-CnuKvHTKSO1v8n74El5SctWWH5PnS6RYc2k9ORuIz78WCk'

const mapsApiKey = 'AIzaSyC-Uji8Ri4-nX59yTWwPOsHMmCRCKgurfo'
const mapsAPikeyProd = 'AIzaSyBVUOk7McaEQ0zSRrlpOMirZ-culbTncKY'

const isDev = process.env.NODE_ENV === 'development'

export const configs = () => {
  return {
    firebaseKeyJson: isDev ? development : production,
    vapidKey: isDev ? vapidKeyDev : vapidKeyProd,
    mapsKey: isDev ? mapsApiKey : mapsAPikeyProd,
  }
}

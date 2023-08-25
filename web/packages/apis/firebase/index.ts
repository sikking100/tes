/* eslint-disable simple-import-sort/imports */
import firebase from 'firebase/compat/app'
import 'firebase/compat/auth'
import 'firebase/compat/storage'
import 'firebase/compat/firestore'
import 'firebase/compat/messaging'

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
    apiKey: "AIzaSyDvFZ56tJPuXUqsETPnWot0JaUXSzL_yjw",
    authDomain: "dairy-food-production.firebaseapp.com",
    projectId: "dairy-food-production",
    storageBucket: "dairy-food-production.appspot.com",
    messagingSenderId: "1033052930232",
    appId: "1:1033052930232:web:91c4048321c614c54fb44d"
}

const vapidKey =
    'BHTiCPjNz5FFKdYD8yi4yKa1jVVw0RzwlP4e0H4G-CnuKvHTKSO1v8n74El5SctWWH5PnS6RYc2k9ORuIz78WCk'

const vapidKeyProd =
    'BIqovDOJ5mECyidUWnQFoFej3OFr_jG0a0BCITaOZpxb16UEDKTAQhsnDt6wIz1pOV95ZlE7ckbZ6OAkAoPM5es'

if (!firebase.apps.length) {
    firebase.initializeApp(
        process.env.NODE_ENV === 'production' ? production : development
    )
}

export const FbApp = firebase.app()
export const FbAuth = firebase.auth()
export const FbStorage = firebase.storage()
export const fbFirestore = firebase.firestore()

export const getTokensFcm = () => {
    return new Promise<string>((resolve, reject) => {
        firebase
            .messaging()
            .getToken({
                vapidKey: process.env.NODE_ENV === 'production' ? vapidKeyProd : vapidKey,
            })
            .then((res) => {
                if (res) {
                    resolve(res)
                } else {
                    resolve('-')
                }
            })
            .catch((e) => {
                reject(e)
                console.error('An error occurred while retrieving token. ', e)
            })
    })
}

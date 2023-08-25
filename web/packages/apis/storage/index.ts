import { getStorage, ref, uploadBytes } from 'firebase/storage'
import { FbApp } from '../firebase'

interface UploadFile {
    file: File
    path: string
    metadata?: { [key: string]: string }
}

const delay = (ms: number) => new Promise((_) => setTimeout(_, ms))
export async function uploadFile({ file, path, metadata }: UploadFile) {
    await uploadBytes(ref(getStorage(FbApp), path), file, {
        customMetadata: metadata,
    })
    await delay(2 * 1000)
}

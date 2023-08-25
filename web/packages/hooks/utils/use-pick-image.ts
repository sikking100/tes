import { useState } from 'react'

type T = 'user' | 'product' | 'brand'

export const usePickImage = (req?: T) => {
  const type =
    req === 'user'
      ? '/default_user.png'
      : req === 'brand'
      ? '/default_brand.png'
      : req === 'product'
      ? '/default_product.png'
      : '/image-thumbnail.png'
  const [preview, setPreview] = useState<string | ArrayBuffer | null>(type)
  const [selectedFile, setSelectedFile] = useState<File | undefined>(undefined)

  const onSelectFile = (e: (EventTarget & HTMLInputElement) | null) => {
    if (!e?.files) return
    if (e.files[0]) {
      setSelectedFile(e.files[0])
      const reader = new FileReader()
      reader.addEventListener('load', () => setPreview(reader.result))
      reader.readAsDataURL(e.files[0])
    }
  }

  return {
    preview,
    selectedFile,
    onSelectFile,
    setPreview,
    setSelectedFile,
  }
}

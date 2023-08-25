import React from 'react'
import Image from 'next/image'

export const AfterHero = () => {
  return (
    <div className='lg:flex lg:flex-row sm:flex-col  justify-center bg-red-600 rounded-2xl'>
      <img alt='hero-image' src='/assets/beranda 2.webp' className='object-fill rounded-xl' />

      <div className='flex flex-col justify-start p-10'>
        <h5 className=' text-white text-[50px] font-semibold mb-2'>
          One-stop-shop for all your bakery needs
        </h5>
        <p className=' text-white text-2xl tracking-wider pt-3'>
          Dairyfood Online adalah aplikasi yang menyediakan segala jenis bahan bakery untuk
          kebutuhan usaha dan rumah tangga Anda
        </p>
      </div>
    </div>
  )
}

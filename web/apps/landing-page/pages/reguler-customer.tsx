import { NextSeo } from 'next-seo'
import React from 'react'
import RegulerCustomerContent from '~/content/reguler-customer'

const RegulerCustomerPages = () => {
  return (
    <div className='pt-[30px] lg:pt-[150px] p-4 lg:p-0'>
      <NextSeo
        title='Dairyfood Internusa'
        description='Halaman home landing page Dairyfood Internusa'
      />

      <RegulerCustomerContent />
    </div>
  )
}

export default RegulerCustomerPages

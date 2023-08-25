import React from 'react'
import data from '~/locales/id/pelanggan-reguler/article.json'

export type RegulerCustomerTypes = {
  _title: string
  _paragraph: string[]
  title: string
  paragraph: string[]
  buttonText: string
  buttonLink: string
  img: string
}

export interface RegulerCustomerProps {
  items: RegulerCustomerTypes[]
}

const RegulerCustomerContent: React.FC = () => {
  return (
    <div>
      {data.items.map((it, idx) => {
        return (
          <div className='lg:flex'>
            <div className='space-y-6 pt-10'>
              <div className='space-y-2'>
                <p className='lg:text-[2.5rem] font-semibold'>{it._title}</p>

                {it._paragraph.map((it, idx) => (
                  <p key={idx} className={'text-lg lg:text-xl'}>
                    {it}
                  </p>
                ))}
              </div>

              <div>
                <p className='lg:text-[2.5rem] font-semibold'>{it.title}</p>
                {it.paragraph.map((it, idx) => (
                  <p key={idx} className={'text-lg lg:text-xl'}>
                    {it}
                  </p>
                ))}
              </div>
            </div>

            <div>
              <img src={it.img} className={'p-10'} />
            </div>
          </div>
        )
      })}
    </div>
  )
}

export default RegulerCustomerContent

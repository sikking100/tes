import React from 'react'
import Image from 'next/image'

export interface HeroTypesAfterSlide {
  heading: Array<string>
  text: string[]
  link: string
  img: string
}

const ForHome: React.FC<HeroTypesAfterSlide> = (props) => {
  return (
    <div className='px-3 bg-white grid lg:grid-cols-2 gap-3 sm:grid-cols-1 '>
      <div className='space-y-10'>
        <div>
          {props.heading.map((it, id) => (
            <h1 key={id} className='text-4xl font-bold tracking-wide'>
              {it}
            </h1>
          ))}
        </div>
        <div className='space-y-3'>
          {props.text.map((it, id) => (
            <p key={id} className='text-xl tracking-wide'>
              {it}
            </p>
          ))}
        </div>
      </div>

      <div className='w-600 h-400'>
        <Image
          src={props.img}
          className='object-contain rounded-md'
          width={600}
          height={400}
          quality={100}
          alt='image'
        />
      </div>
    </div>
  )
}

export default ForHome

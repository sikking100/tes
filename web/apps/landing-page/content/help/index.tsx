import React from 'react'
import Link from 'next/link'
import useMediaQuery from '~/config/use-media-query'

export type HelpTypes = {
  title: string[]
  text: string
  link: string
  linkText: string
  img: string
}
const HelpContent: React.FC<HelpTypes> = (props) => {
  const isDesktop = useMediaQuery('(min-width: 1024px)')

  return (
    <div className='p-3 lg:p-0'>
      <div className='space-y-1 lg:space-y-8'>
        {props.title.map((itx, idx) => (
          <h2 key={idx} className='text-xl font-semibold lg:text-left lg:text-[3rem]'>
            {itx}
          </h2>
        ))}
      </div>
      <p className='pt-2 text-lg lg:pt-7'>{props.text}</p>
      <div className='flex'>
        <a href={props.link} className='font-semibold underline'>
          {props.linkText}
        </a>
      </div>

      <div className='lg:px-40'>
        <img src={props.img} className={'lg:h-[600px] lg:w-[100%] object-contain'} />
      </div>
    </div>
  )
}

export default HelpContent

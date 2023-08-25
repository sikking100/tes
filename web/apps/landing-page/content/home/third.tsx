import React from 'react'
import Image from 'next/image'
import dynamic from 'next/dynamic'

const AliceCarousel = dynamic(() => import('react-alice-carousel'), {
  ssr: false,
})

interface SlidePropsTypes {
  name: string
  img: string
}

export interface SlideProps {
  title: string
  products: SlidePropsTypes[]
}

const responsive = {
  0: { items: 2 },
  568: { items: 2 },
  1024: { items: 7 },
}

const items = (props: SlidePropsTypes[]): JSX.Element[] => {
  const i = []

  for (let index = 0; index < props.length; index++) {
    i.push(
      <div className='w-[150] h-100  bg-white flex bg-center'>
        <Image
          src={props[index].img}
          alt={props[index].name}
          className='object-fill rounded-md'
          width={140}
          height={140}
          quality={100}
        />
      </div>,
    )
  }

  return i
}

const ThirdSection: React.FC<SlideProps> = ({ products, title }) => {
  return (
    <div className='bg-[#FFF8EE] mt-100'>
      <div className='mt-100 p-10 space-y-10'>
        <p className='text-2xl text-center'>{title}</p>
        <AliceCarousel
          mouseTracking
          autoPlay={true}
          animationType='fadeout'
          items={items(products)}
          responsive={responsive}
          // disableDotsControls
          disableButtonsControls
        >
          {products.map((it, id) => (
            <div
              key={id}
              className='bg-white h-[130px] w-[130px] p-3 rounded-lg flex items-center shadow-sm'
            >
              <Image
                key={id}
                alt={it.name}
                src={it.img}
                width={300}
                height={300}
                className='object-fill rounded-md'
              />
            </div>
          ))}
        </AliceCarousel>
      </div>
    </div>
  )
}

export default ThirdSection

import React from 'react'
import useMediaQuery from '~/config/use-media-query'

export type ArticlePropsTypes = {
    id?: number
    title: string
    paragraph: string[]
    buttonText: string
    buttonLink: string
    img: string
}

export interface ArticleProps {
    items: ArticlePropsTypes[]
}

const Desktop: React.FC<ArticleProps> = (props) => (
    <div className="mt-40 container mx-auto lg:px-[100px] space-y-20">
        {props.items.map((i, k) => {
            if (k % 2 === 0) {
                return (
                    <div
                        key={k}
                        className={`lg:flex space-x-10 p-4 justify-between`}
                    >
                        <div className={` bg-white shadow-md rounded-md p-5`}>
                            <img
                                src={i.img}
                                className="object-contain w-[300px] h-[250px]"
                            />
                        </div>
                        <div className={`col-span-3 space-y-5 tracking-wide`}>
                            <h1 className="text-3xl font-bold">{i.title}</h1>
                            {i.paragraph.map((p, k) => (
                                <p className="text-lg" key={k}>
                                    {p}
                                </p>
                            ))}
                        </div>
                    </div>
                )
            } else {
                return (
                    <div
                        key={k}
                        className={`lg:flex space-x-10 justify-between`}
                    >
                        <div className={`col-span-3 space-y-5 tracking-wide`}>
                            <h1 className="text-3xl font-bold">{i.title}</h1>
                            {i.paragraph.map((p, k) => (
                                <p className="text-lg" key={k}>
                                    {p}
                                </p>
                            ))}
                        </div>
                        <div className={` bg-white shadow-md rounded-md p-5`}>
                            <img
                                src={i.img}
                                className="object-contain w-[300px] h-[250px]"
                            />
                        </div>
                    </div>
                )
            }
        })}
    </div>
)

const Mobile: React.FC<ArticleProps> = (props) => (
    <div className="mt-10 container mx-auto lg:px-[100px] space-y-10">
        {props.items.map((i, k) => {
            return (
                <div key={k} className={`p-4 space-y-3`}>
                    <div className={` bg-white shadow-md rounded-lg p-5`}>
                        <img
                            src={i.img}
                            className="object-contain w-[300px] h-[250px]"
                        />
                    </div>
                    <div className={`space-y-5 tracking-wide text-start`}>
                        <h1 className="text-3xl font-bold">{i.title}</h1>
                        <p className="text-lg">{i.paragraph}</p>
                    </div>
                </div>
            )
        })}
    </div>
)

const Layanan: React.FC<ArticleProps> = (props) => {
    const isDesktop = useMediaQuery('(min-width: 960px)')

    if (isDesktop) return <Desktop items={props.items} />
    return <Mobile items={props.items} />
}

export default Layanan

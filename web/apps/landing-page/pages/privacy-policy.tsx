import { GetStaticProps, InferGetStaticPropsType, NextPage } from 'next'
import { NextSeo } from 'next-seo'
import React from 'react'
import { parseData } from '~/config/get-data'

interface halMencakup {
    title: string
    hal: string[]
}

interface isiHalTypes {
    title: string
    isi: string[]
}

interface HalTypes {
    title: string
    paragraph: string
    isi_hal: isiHalTypes[]
}

export interface PrivacyPoliciesTypes {
    title: string[]
    pengantar: string[]
    hal_mencakup: halMencakup
    hal: HalTypes[]
}

export const getStaticProps: GetStaticProps = async () => {
    const locale = 'id'
    const items = (await parseData(
        '/aggreement/privacy.json',
        locale
    )) as PrivacyPoliciesTypes

    return {
        props: {
            items,
        },
    }
}

interface PrivacyPoliciesPagesProps
    extends InferGetStaticPropsType<typeof getStaticProps> {
    items: PrivacyPoliciesTypes
}

const TermConditionPages: NextPage<PrivacyPoliciesPagesProps> = (props) => {
    return (
        <div className="lg:mt-[100px] p-5">
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home landing page Dairyfood Internusa"
            />

            <div className="space-y-3 leading-relaxed">
                {props.items.title.map((item, index) => (
                    <h1 key={index} className="text-xl font-bold">
                        {item}
                    </h1>
                ))}

                <div className="space-y-3 leading-relaxed">
                    {props.items.pengantar.map((p, idx) => (
                        <p key={idx} className="">
                            {p}
                        </p>
                    ))}
                </div>
            </div>

            {/*  */}

            <div className="mt-5 leading-relaxed">
                <p>{props.items.hal_mencakup.title}</p>
                <ol className="space-y-2 list-decimal pl-3">
                    <>
                        {props.items.hal_mencakup.hal.map((h, i) => (
                            <li key={i}>{h}</li>
                        ))}
                    </>
                </ol>
            </div>

            {/*  */}

            {props.items.hal.map((i, k) => (
                <div key={k} className="space-y-3 pt-10">
                    <div className="leading-relaxed">
                        <h1 className="text-lg font-bold">{i.title}</h1>
                        <h1 className="">{i.paragraph}</h1>
                    </div>
                    {i.isi_hal.map((itx, idx) => (
                        <div key={idx} className="leading-relaxed">
                            {itx.title.length > 0 && (
                                <ul>
                                    <li className="font-[600]">{itx.title}</li>
                                </ul>
                            )}
                            <p>{itx.isi}</p>
                        </div>
                    ))}
                </div>
            ))}
        </div>
    )
}

export default TermConditionPages

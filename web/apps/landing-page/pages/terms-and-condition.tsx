import { GetStaticProps, InferGetStaticPropsType, NextPage } from 'next'
import { NextSeo } from 'next-seo'
import React from 'react'
import { parseData } from '~/config/get-data'

interface subTypes {
    title: string
    isi: string[]
}

interface halTypes {
    title: string
    paragraph: string[]
    sub: subTypes[]
}

export interface TermsConditionProps {
    title: string[]
    pengantar: string[]
    hal: halTypes[]
}

interface TermsAndConditionPagesProps
    extends InferGetStaticPropsType<typeof getStaticProps> {
    items: TermsConditionProps
}

export const getStaticProps: GetStaticProps = async () => {
    const locale = 'id'
    const items = (await parseData(
        '/aggreement/terms.json',
        locale
    )) as TermsConditionProps

    return {
        props: {
            items,
        },
    }
}

const PrivacyPolicyPages: NextPage<TermsAndConditionPagesProps> = (props) => {
    return (
        <div className="mt-[80px] p-5 lg:mt-[100px] lg:p-0">
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home landing page Dairyfood Internusa"
            />

            <div className="space-y-3">
                {props.items.title.map((item, index) => (
                    <h1 key={index} className="text-xl font-bold">
                        {item}
                    </h1>
                ))}

                <p className="justify-start">{props.items.pengantar}</p>
            </div>

            <div className="mt-4">
                {props.items.hal.map((it, ix) => {
                    return (
                        <div key={ix} className="flex flex-col space-y-5">
                            <div className="space-y-3">
                                <h1 className="text-lg">{it.title}</h1>
                                {it.paragraph.map((itp, idp) => (
                                    <p key={idp} className="justify-start">
                                        {itp}
                                    </p>
                                ))}
                            </div>

                            {it.sub.map((itx, idx) => {
                                return (
                                    <div className="flex flex-row">
                                        {itx.title.length > 0 && (
                                            <>
                                                <p>{itx.title}</p>
                                                <ol>
                                                    <>
                                                        {itx.isi.map(
                                                            (itz, idz) => {
                                                                itz.length >
                                                                    0 && (
                                                                    <li
                                                                        key={
                                                                            idz
                                                                        }
                                                                    >
                                                                        {itz}
                                                                    </li>
                                                                )
                                                            }
                                                        )}
                                                    </>
                                                </ol>
                                            </>
                                        )}
                                    </div>
                                )
                            })}
                        </div>
                    )
                })}
            </div>
        </div>
    )
}

export default PrivacyPolicyPages

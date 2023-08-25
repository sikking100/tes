import { GetStaticProps, InferGetStaticPropsType, NextPage } from 'next'
import { NextSeo } from 'next-seo'
import React from 'react'
import { parseData } from '~/config/get-data'
import Layanan, { ArticleProps } from '~/content/service'

export const getStaticProps: GetStaticProps = async () => {
    const locale = 'id'
    const items = (await parseData(
        '/layanan/article.json',
        locale
    )) as ArticleProps
    return {
        props: {
            items,
        },
    }
}

interface LayananPagesProps
    extends InferGetStaticPropsType<typeof getStaticProps> {
    items: ArticleProps
}

const ServicePages: NextPage<LayananPagesProps> = ({ items }) => {
    return (
        <div>
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman layanan landing page Dairyfood Internusa"
            />
            <Layanan items={items.items} />
        </div>
    )
}

export default ServicePages

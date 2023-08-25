import React, { useEffect } from 'react'
import { GetStaticProps, InferGetStaticPropsType, NextPage } from 'next'
import { NextSeo } from 'next-seo'
import { ctxProvider } from 'context'
import Hero from '~/content/home/hero'
import { AfterHero } from '~/content/home/after-hero'
import ThirdSection, { SlideProps } from '~/content/home/third'
import { parseData } from '~/config/get-data'
import ForHome, { HeroTypesAfterSlide } from '~/content/home/for'

interface HomePageProps extends InferGetStaticPropsType<typeof getStaticProps> {
    kategori: SlideProps
    afterKategori: HeroTypesAfterSlide
}

export const getStaticProps: GetStaticProps = async () => {
    const locale = 'id'

    const kategori = (await parseData(
        '/home/kategori.json',
        locale
    )) as SlideProps
    const afterKategori = (await parseData(
        '/home/afterKategori.json',
        locale
    )) as HeroTypesAfterSlide

    return {
        props: {
            kategori,
            afterKategori,
        },
    }
}

const HomePage: NextPage<HomePageProps> = (props) => {
    const { setActivenav } = ctxProvider()

    useEffect(() => {
        setActivenav(1)
    }, [])

    return (
        <div className="">
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home landing page Dairyfood Internusa"
            />

            <Hero />
            <div className="space-y-20">
                <AfterHero />
                <ThirdSection {...props.kategori} />
                <ForHome {...props.afterKategori} />
            </div>
        </div>
    )
}

export default HomePage

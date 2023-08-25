import { GetStaticProps, InferGetStaticPropsType, NextPage } from 'next'
import { NextSeo } from 'next-seo'
import { parseData } from '~/config/get-data'
import HelpContent, { HelpTypes } from '~/content/help'

interface HelpPagesProps
    extends InferGetStaticPropsType<typeof getStaticProps> {
    items: HelpTypes
}

export const getStaticProps: GetStaticProps = async () => {
    const locale = 'id'
    const items = (await parseData('/help/items.json', locale)) as HelpTypes
    return {
        props: {
            items,
        },
    }
}

const HelpPages: NextPage<HelpPagesProps> = (props) => {
    return (
        <div className="mt-[80px] lg:mt-[100px]">
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home landing page Dairyfood Internusa"
            />

            <HelpContent {...props.items} />
        </div>
    )
}

export default HelpPages

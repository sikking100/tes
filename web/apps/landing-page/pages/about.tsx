import { NextSeo } from 'next-seo'
import React from 'react'

const AboutPages = () => {
    return (
        <div>
            <NextSeo
                title="Dairyfood Internusa"
                description="Halaman home landing page Dairyfood Internusa"
            />

            <div className="p-2 justify-self-center mt-20 lg:mt-40 lg:flex lg:space-x-3 lg:p-0">
                <div className="space-y-5">
                    <h2 className="text-2xl lg:text-4xl font-bold">
                        PT Dairyfood Internusa
                    </h2>

                    <p className="lg:text-xl tracking-normal">
                        PT Dairyfood Internusa (Dairyfood) adalah perusahaan
                        nasional yang bergerak dibidang distribusi produk-produk
                        bakery untuk segment HORECA dan toko retail.
                    </p>

                    <p className="lg:text-xl tracking-normal ">
                        Di tahun 2021, Dairyfood menambahkan layanan belanja
                        online sebagai salah satu wujud transformasi digital
                        untuk memberikan pelayanan yang lebih prima serta
                        menjangkau pasar yang lebih luas.
                    </p>
                </div>

                <div className="w-100 mt-10 lg:w-300 lg:mt-0">
                    <img
                        src="/assets/tentang-kamiq.webp"
                        className="object-cover w-[100em] rounded-xl"
                    />
                </div>
            </div>
        </div>
    )
}

export default AboutPages

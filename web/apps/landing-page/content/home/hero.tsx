import React from 'react'
import Image from 'next/image'

const Hero = () => {
    return (
        <div className="px-1 py-12 md:px-12 text-gray-800 text-center lg:text-left">
            <div className="container mx-auto xl:px-20">
                <div className="grid lg:grid-cols-2 gap-12 items-center">
                    <div className="mt-12 lg:mt-0 space-y-3">
                        <h1 className="text-5xl md:text-6xl xl:text-7xl font-semibold tracking-tight mb-12 space-y-3">
                            Dairyfood Online
                            <br />
                            <p className="text-red-600">
                                Bringing the world's best
                            </p>
                            <p className="text-5xl font-medium">
                                bakery ingredients to you
                            </p>
                        </h1>

                        <div className="inline-flex space-x-5">
                            <div className="w-[150] h-100">
                                <Image
                                    src="/logo-ios-apps/app-store.webp"
                                    className="object-fill rounded-md"
                                    width={150}
                                    height={100}
                                    quality={100}
                                    alt="app-store"
                                    onClick={() => {
                                        window.open(
                                            'https://play.google.com/store/apps/details?id=app.dairyfood.customer',
                                            '_blank'
                                        )
                                    }}
                                />
                            </div>
                            <div className="w-[150] h-100">
                                <Image
                                    src="/logo-ios-apps/play-store.webp"
                                    className="object-fill rounded-md"
                                    width={150}
                                    height={100}
                                    quality={100}
                                    alt="app-store"
                                    onClick={() => {
                                        window.open(
                                            'https://www.apple.com/app-store/developing-for-the-app-store/',
                                            '_blank'
                                        )
                                    }}
                                />
                            </div>
                        </div>
                    </div>
                    <div className="mb-12 lg:mb-0 lg:p-[100px] ">
                        <img
                            src="/hero/hero-img.png"
                            className="w-full rounded-lg"
                            alt=""
                        />
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Hero

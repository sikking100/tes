import { useEffect, useState } from 'react'

/**
 * @param value number
 * @returns boolean
 */

export function isEven(value: number) {
    if (value % 2 == 0) return true
    // genap
    else return false //ganjil
}

/**
 * Handle Detect Device
 * @returns
 */

export const useDevice = () => {
    const [firstLoad, setFirstLoad] = useState(true)
    useEffect(() => {
        setFirstLoad(false)
    }, [])

    const ssr = firstLoad || typeof navigator === 'undefined'
    const isAndroid = !ssr && /android/i.test(navigator.userAgent)
    const isIos = !ssr && /iPad|iPhone|iPod/.test(navigator.userAgent)
    return {
        isAndroid,
        isIos,
        isDesktop: !isAndroid && !isIos,
    }
}

/**
 * Setting For Slider
 */

export const settings = {
    dots: false,
    autoplay: true,
    autoplaySpeed: 2500,
    infinite: true,
    slidesToShow: 1,
    slidesToScroll: 1,
    initialSlide: 0,
    speed: 2500,
    arrows: false,
    adaptiveHeight: true,
    cssEase: 'linear',
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    appendDots: (dots: any) => <ul>{dots}</ul>,
    // eslint-disable-next-line react/display-name
    customPaging: () => (
        <div className="ft-slick__dots--custom">
            <div className="loading" />
        </div>
    ),
}

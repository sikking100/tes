import React from 'react'
import Footer from './layout/footer'
import Navbar from './layout/navbar'

interface ContainerProps {
    children: React.ReactNode
}

export const Container: React.FC<ContainerProps> = (props) => {
    return (
        <div className="h-full">
            {/*  */}
            <Navbar />
            <div className="container items-center justify-between mx-auto h-full">
                {props.children}
            </div>
            <Footer />
        </div>
    )
}

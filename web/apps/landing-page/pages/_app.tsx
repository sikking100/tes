import '../styles/globals.css'
import 'react-alice-carousel/lib/alice-carousel.css'
import 'react-toastify/dist/ReactToastify.css'
import type { AppProps } from 'next/app'
import { Container } from 'components'
import Provider from 'context'
import { ToastContainer, Slide } from 'react-toastify'

const MyApp = ({ Component, pageProps }: AppProps) => {
    return (
        <Provider>
            <Container>
                <Component {...pageProps} />
                <ToastContainer
                    position="bottom-right"
                    autoClose={5000}
                    hideProgressBar
                    newestOnTop={false}
                    closeOnClick
                    rtl={false}
                    pauseOnFocusLoss
                    draggable
                    pauseOnHover
                    theme="colored"
                    transition={Slide}
                    className="text-sm font-sans"
                />
            </Container>
        </Provider>
    )
}

export default MyApp

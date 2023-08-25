import { RouterProvider, createBrowserRouter } from 'react-router-dom'
import HomePages from './pages/home'
import Login from './pages/login'
import HelpPages from './pages/profile/help/help'
import ProfilePage from './pages/profile/profile'
import QuestionPages from './pages/profile/question/question'
import CourierPages from './pages/courier/courier'
import ProductQtyPages from './pages/products/qty/product-qty'
import OrderPages from './pages/orders/order'
import { PrivateRoute } from 'ui'
import QtyHistoryPages from './pages/products/qty-history/qty-history'
import PagelistDeliveryPacking from './pages/orders/delivery/delivery'
import DetailDelivery from './pages/orders/order/tracking-delivery'

const router = createBrowserRouter([
    {
        path: '/login',
        element: <Login />,
    },
    {
        path: '/',
        element: <PrivateRoute components={<HomePages />} />,
    },
    {
        path: '/account',
        element: <PrivateRoute components={<CourierPages />} />,
    },
    {
        path: '/order',
        element: <PrivateRoute components={<OrderPages />} />,
    },
    {
        path: '/tracking-delivery/:deliveryId',
        element: <PrivateRoute components={<DetailDelivery />} />,
    },
    {
        path: '/help',
        element: <PrivateRoute components={<HelpPages />} />,
    },
    {
        path: '/question',
        element: <PrivateRoute components={<QuestionPages />} />,
    },
    {
        path: '/profile',
        element: <PrivateRoute components={<ProfilePage />} />,
    },
    {
        path: '/product',
        element: <PrivateRoute components={<ProductQtyPages />} />,
    },
    {
        path: '/qty-history',
        element: <PrivateRoute components={<QtyHistoryPages />} />,
    },
    {
        path: '/delivery-packinglist',
        element: <PrivateRoute components={<PagelistDeliveryPacking />} />,
    },
])

const App = () => {
    return (
        <div className="App">
            <RouterProvider router={router} />
        </div>
    )
}

export default App

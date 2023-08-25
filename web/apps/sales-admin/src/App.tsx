import { RouterProvider, createBrowserRouter } from 'react-router-dom'
import HomePages from './pages/home'
import ProductPages from './pages/product/product/product'
import OrderPages from './pages/order/new/order'
import RecipePages from './pages/recipe/recipe'
import UserPages from './pages/user/user'
import { PrivateRoute } from 'ui'
import LoginPages from './pages/login'
import CodePages from './pages/product/code/code'
import ProfilePage from './pages/profile/profile'
import HelpPages from './pages/profile/help/help'
import QuestionPages from './pages/profile/question/question'
import CustomerApplyPages from './pages/business/customer-apply'
import OrderApplyPages from './pages/order/apply/order-apply'
import MyOrderPages from './pages/order/new/my-order'
import { OrderCreatePages } from './pages/order/new/create-order'
import CategoryPages from './pages/product/category/category'
import OrderExportDataPages from './pages/report/report-pages'
import TrackingDelivery from './pages/order/new/tracking-delivery'

const router = createBrowserRouter([
    {
        path: '/login',
        element: <LoginPages />,
    },
    {
        path: '/',
        element: <PrivateRoute components={<HomePages />} />,
    },
    {
        path: '/recipe',
        element: <PrivateRoute components={<RecipePages />} />,
    },
    {
        path: '/user',
        element: <PrivateRoute components={<UserPages />} />,
    },
    {
        path: 'customer-apply',
        element: <PrivateRoute components={<CustomerApplyPages />} />,
    },
    {
        path: '/code',
        element: <PrivateRoute components={<CodePages />} />,
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
        path: '/category-product',
        element: <PrivateRoute components={<CategoryPages />} />,
    },
    {
        path: '/report',
        element: <PrivateRoute components={<OrderExportDataPages />} />,
    },
    {
        path: '/product',
        element: <PrivateRoute components={<ProductPages />} />,
    },
    {
        path: '/order',
        element: <PrivateRoute components={<OrderPages />} />,
    },
    {
        path: '/order-create',
        element: <PrivateRoute components={<OrderCreatePages />} />,
    },
    {
        path: '/order-me',
        element: <PrivateRoute components={<MyOrderPages />} />,
    },
    {
        path: '/delivery-tracking/:deliveryId',
        element: <PrivateRoute components={<TrackingDelivery />} />,
    },
    {
        path: '/order-approval',
        element: <PrivateRoute components={<OrderApplyPages />} />,
    },
    {
        path: '/profile',
        element: <PrivateRoute components={<ProfilePage />} />,
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

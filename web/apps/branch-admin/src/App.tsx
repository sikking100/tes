import { PrivateRoute } from 'ui'
import ActivityPages from './pages/activity/activity'
import HomePages from './pages/home'
import LoginPages from './pages/login'
import HelpPages from './pages/profile/help/help'
import ProfilePage from './pages/profile/profile'
import QuestionPages from './pages/profile/question/question'
import BusinessPages from './pages/submission/business'
import UserPages from './pages/users/users'
import CustomerPages from './pages/customer/customer'

import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import WarehousePages from './pages/warehouse/warehouse'

const router = createBrowserRouter([
    {
        path: '/',
        element: <PrivateRoute components={<HomePages />} />,
    },
    {
        path: '/login',
        element: <LoginPages />,
    },
    {
        path: '/customer',
        element: <PrivateRoute components={<CustomerPages />} />,
    },
    {
        path: '/submission-business',
        element: <PrivateRoute components={<BusinessPages />} />,
    },
    {
        path: '/account',
        element: <PrivateRoute components={<UserPages />} />,
    },
    {
        path: '/warehouse',
        element: <PrivateRoute components={<WarehousePages />} />,
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
        path: '/activity',
        element: <PrivateRoute components={<ActivityPages />} />,
    },
    {
        path: '/profile',
        element: <PrivateRoute components={<ProfilePage />} />,
    },
])

function App() {
    return (
        <div>
            <RouterProvider router={router} />
        </div>
    )
}

export default App

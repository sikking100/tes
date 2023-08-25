import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import { PrivateRoute } from 'ui'
import BranchPages from './pages/branch/branch'
import HomePages from './pages/home'
import Login from './pages/login'
import BrandPages from './pages/products/brand/brand'
import CategoryPages from './pages/products/category/category'
import ProductPages from './pages/products/product/product'
import HelpPages from './pages/profile/help/help'
import ProfilePage from './pages/profile/profile'
import RegionPages from './pages/region/region'
import UserPages from './pages/users/users'
import BannerPages from './pages/banner/banner'
import ActivityPages from './pages/activity/activity'
import RegionImportPreviewPages from './pages/region/region-import-preview'
import PriceeListPages from './pages/products/price-list/price-list'
import PriceImport from './pages/branch/import-price'
import QtyImportPages from './pages/branch/import-qty'
import QtyHistoryPages from './pages/products/qty-history/qty-history'
import QuestionPages from './pages/profile/question/question'
import ProductImportPages from './pages/products/product/product-import'
import CategoryImportPages from './pages/products/category/category-import'
import PriceListImportPages from './pages/products/price-list/price-list-import'
import BrandImportPages from './pages/products/brand/brand-preview-import'
import BranchImportPreviewPages from './pages/branch/branch-import-preview'
import AccountImportPreviewPages from './pages/users/users-import-view'

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
        element: <PrivateRoute components={<UserPages />} />,
    },
    {
        path: '/import-account',
        element: <PrivateRoute components={<AccountImportPreviewPages />} />,
    },
    {
        path: '/question',
        element: <PrivateRoute components={<QuestionPages />} />,
    },
    {
        path: '/help',
        element: <PrivateRoute components={<HelpPages />} />,
    },
    {
        path: '/product',
        element: <PrivateRoute components={<ProductPages />} />,
    },
    {
        path: '/product-import',
        element: <PrivateRoute components={<ProductImportPages />} />,
    },
    {
        path: '/region',
        element: <PrivateRoute components={<RegionPages />} />,
    },
    //
    {
        path: '/branch',
        children: [
            {
                index: true,
                element: <PrivateRoute components={<BranchPages />} />,
            },
            {
                path: 'price/:id',
                element: <PrivateRoute components={<PriceImport />} />,
            },
            {
                path: 'qty/:id',
                element: <PrivateRoute components={<QtyImportPages />} />,
            },
        ],
    },
    {
        path: '/branch-import',
        element: <PrivateRoute components={<BranchImportPreviewPages />} />,
    },
    {
        path: '/category',
        element: <PrivateRoute components={<CategoryPages />} />,
    },
    {
        path: '/category-import',
        element: <PrivateRoute components={<CategoryImportPages />} />,
    },
    {
        path: '/activity',
        element: <PrivateRoute components={<ActivityPages />} />,
    },
    {
        path: '/banner',
        element: <PrivateRoute components={<BannerPages />} />,
    },
    {
        path: '/price-list',
        element: <PrivateRoute components={<PriceeListPages />} />,
    },
    {
        path: '/price-list-import',
        element: <PrivateRoute components={<PriceListImportPages />} />,
    },
    {
        path: '/brand',
        element: <PrivateRoute components={<BrandPages />} />,
    },
    {
        path: '/brand-import',
        element: <PrivateRoute components={<BrandImportPages />} />,
    },
    {
        path: '/region-import',
        element: <PrivateRoute components={<RegionImportPreviewPages />} />,
    },

    {
        path: '/profile',
        element: <PrivateRoute components={<ProfilePage />} />,
    },
    {
        path: '/qty-history',
        element: <PrivateRoute components={<QtyHistoryPages />} />,
    },
])

const App = () => {
    return (
        <div>
            <RouterProvider router={router} />
        </div>
    )
}

export default App

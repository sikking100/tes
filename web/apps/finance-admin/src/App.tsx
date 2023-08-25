import { RouterProvider, createBrowserRouter } from "react-router-dom";
import { PrivateRoute } from "ui";
import CustomerPages from "./pages/customer/customer";
import HomePages from "./pages/home";
import Login from "./pages/login";
import ProductPages from "./pages/product/product";
import HelpPages from "./pages/profile/help/help";
import ProfilePage from "./pages/profile/profile";
import QuestionPages from "./pages/profile/question/question";
import CustomerApplyPages from "./pages/business/business";
import OrderApplyPages from "./pages/order-apply";

import OrderPages from "./pages/new-order/order";
import InvoicePrintPage from "./pages/new-order/invoice-print";
import OrderExportDataPages from "./pages/new-order/order-export-data";

const router = createBrowserRouter([
  {
    path: "/",
    element: <PrivateRoute components={<HomePages />} />,
  },
  {
    path: "login",
    element: <Login />,
  },
  {
    path: "/profile",
    element: <PrivateRoute components={<ProfilePage />} />,
  },
  {
    path: "/question",
    element: <PrivateRoute components={<QuestionPages />} />,
  },

  {
    path: "/help",
    element: <PrivateRoute components={<HelpPages />} />,
  },

  {
    path: "/order",
    element: <PrivateRoute components={<OrderPages />} />,
  },

  {
    path: "/order-approval",
    element: <PrivateRoute components={<OrderApplyPages />} />,
  },
  {
    path: "/customer",
    element: <PrivateRoute components={<CustomerPages />} />,
  },
  {
    path: "/apply",
    element: <PrivateRoute components={<CustomerApplyPages />} />,
  },
  {
    path: "/product",
    element: <PrivateRoute components={<ProductPages />} />,
  },
  {
    path: "/invoice-print",
    element: <PrivateRoute components={<InvoicePrintPage />} />,
  },
  {
    path: "/report",
    element: <PrivateRoute components={<OrderExportDataPages />} />,
  },
]);

function App() {
  return (
    <div>
      <RouterProvider router={router} />
    </div>
  );
}

export default App;

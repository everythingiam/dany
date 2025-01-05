import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import MenuLayout from './MenuLayout';
import Login from '../pages/Login';
import Registration from '../pages/Registration';
import Games from '../pages/Games';
import ErrorPage from '../pages/ErrorPage';
import PasswordRecovery from '../pages/PasswordRecovery';
import Create from '../pages/Create';
import RequireAuth from '../hoc/RequireAuth';
import Account from '../pages/Account';
import Room from '../pages/Room';

const routes = createBrowserRouter([
  {
    path: '/',
    element: <MenuLayout />,
    children: [
      { path: 'login', element: <Login /> },
      { path: 'registration', element: <Registration /> },
      { path: 'recovery', element: <PasswordRecovery /> },
      {
        path: 'create',
        element: (
          <RequireAuth>
            <Create />
          </RequireAuth>
        ),
      },
      {
        path: 'account',
        element: (
          <RequireAuth>
            <Account />
          </RequireAuth>
        ),
      },
      {
        index: true,
        element: (
          <RequireAuth>
            <Games />
          </RequireAuth>
        ),
      },
    ],
    errorElement: <ErrorPage />,
  },
  {
    path: 'room',
    element: (
      <Room />
    ),
  },
]);

const AppRouter = () => {
  return (
    <RouterProvider router={routes} />
  );
};

export default AppRouter;

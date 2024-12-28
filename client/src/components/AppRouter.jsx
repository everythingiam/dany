import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import MenuLayout from './MenuLayout';
import '../styles/common.scss';
import Login from '../pages/Login';
import Registration from '../pages/Registration';
import GamesList from '../pages/GamesList';
import ErrorPage from '../pages/ErrorPage';
import PasswordRecovery from '../pages/PasswordRecovery';
import Create from '../pages/Create';
import RequireAuth from '../hoc/RequireAuth';
import Account from '../pages/Account';

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
            <GamesList />
          </RequireAuth>
        ),
      },
    ],
    errorElement: <ErrorPage />,
  },
]);

const AppRouter = () => {
  return (
    <RouterProvider router={routes} />
  );
};

export default AppRouter;

import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import MenuLayout from './components/MenuLayout';
import './styles/common.scss';
import Login from './pages/Login';
import Registration from './pages/Registration';
import GamesList from './pages/GamesList';
import ErrorPage from './pages/ErrorPage';
import PasswordRecovery from './pages/PasswordRecovery';
import Create from './pages/Create';

const router = createBrowserRouter([
  {
    path: '/',
    element: <MenuLayout />,
    children: [
      { path: 'login', element: <Login /> },
      { path: 'registration', element: <Registration /> },
      { path: 'recovery', element: <PasswordRecovery /> },
      { path: 'create', element: <Create /> },
      {
        index: true,
        element: <GamesList />
        ,
      },
    ],
    errorElement: <ErrorPage />,
  },
]);

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>
);

import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { Link, Outlet } from 'react-router-dom';
import Dany from '../assets/danylogo.svg';
import IconButton from '../UI/IconButton';
import UserService from '../API/UserService';

import '../styles/menu.scss';

const MenuLayout = () => {
  const { signout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    await UserService.logout();
    signout(() => navigate('/login', { replace: true }));
  };

  const shouldRenderLogout = !['/login', '/registration', '/recovery'].includes(location.pathname);

  return (
    <>
      <Link to="/" className="dany-icon">
        <img src={Dany} alt="danyicon" />
      </Link>
      <div className="info">
        <IconButton icon={'question'} text="Правила" />
        <IconButton icon={'info'} text="Создание" />
      </div>

      {shouldRenderLogout && (
        <div className="else">
          <IconButton
            icon={'arrow-left'}
            text="Выйти"
            onClick={handleLogout}
          />
        </div>
      )}

      <main>
        <Outlet />
      </main>
    </>
  );
};

export default MenuLayout;

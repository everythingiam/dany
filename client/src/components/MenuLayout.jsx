import { useNavigate, useLocation } from 'react-router-dom';
import { Link, Outlet } from 'react-router-dom';
import Dany from '../assets/danylogo.svg';
import IconButton from '../UI/IconButton';
import UserService from '../API/UserService';
import { useFetching } from '../hooks/useFetching';
import { useEffect, useState } from 'react';

import '../styles/menu.scss';

const MenuLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [avatar, setAvatar] = useState('');
  const [name, setName] = useState('');

  const [fetchUserData, isLoading] = useFetching(async () => {
    const response = await UserService.getUserData();
    const avatarPath = `/avatars/${response.data.avatar}`;
    setAvatar(avatarPath);
    setName(response.data.login);
  });

  useEffect(() => {
    fetchUserData();
  }, []);

  if (isLoading) {
    return <h1>Loading...</h1>;
  }

  const handleAvatar = async () => {
    navigate('/profile', { replace: true });
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
            icon={'avatar'}
            text={name}
            src={avatar}
            onClick={handleAvatar}
          />
        </div>
      )}

      <main className='menu'>
        <Outlet />
      </main>
    </>
  );
};

export default MenuLayout;

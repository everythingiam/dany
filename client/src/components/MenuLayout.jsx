import { useNavigate, useLocation } from 'react-router-dom';
import { Link, Outlet } from 'react-router-dom';
import Dany from '../assets/danylogo.svg';
import IconButton from '../UI/IconButton';
import UserService from '../API/UserService';
import { useFetching } from '../hooks/useFetching';
import { useEffect, useState } from 'react';
import AuthorsModal from './AuthorsModal';

import '../styles/menu.scss';
import RulesModal from './RulesModal';

const MenuLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [avatar, setAvatar] = useState('');
  const [name, setName] = useState('');
  const [authorsShow, setAuthorsShow] = useState(false);
  const [rulesShow, setRulesShow] = useState(false);

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
        <IconButton icon={'question'} text="Правила" onClick={() => setRulesShow(true)}/>
        <IconButton icon={'info'} text="Создание" onClick={() => setAuthorsShow(true)} />
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

      <AuthorsModal show={authorsShow} onHide={() => setAuthorsShow(false)}/>
      <RulesModal show={rulesShow} onHide={() => setRulesShow(false)}/>

      <main className='menu'>
        <Outlet />
      </main>
    </>
  );
};

export default MenuLayout;

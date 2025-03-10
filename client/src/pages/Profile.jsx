import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import UserService from '../API/UserService';
import ProgressiveImage from '../components/ProgressiveImage';
import { useFetching } from '../hooks/useFetching';
import placeholderSrc from '../assets/white.svg';

const Profile = () => {
  const [avatar, setAvatar] = useState('');
  const [name, setName] = useState('');
  const { signout } = useAuth();
  const navigate = useNavigate();
  const [choosedImg, setChoosedImg] = useState('');

  const images = ['1.png', '2.png', '3.png', '4.png', '5.png', 'default.png'];

  const [fetchUserData, isLoading] = useFetching(async () => {
    const response = await UserService.getUserData();
    const avatarPath = `/avatars/${response.avatar}`;
    setAvatar(avatarPath);
    setChoosedImg(response.avatar);
    setName(response.login);
  });

  useEffect(() => {
    fetchUserData();
  }, []);

  if (isLoading) {
    return <h1>Loading...</h1>;
  }

  const handleClick = (img) => {
    setChoosedImg(img);
    setAvatar(`/avatars/${img}`);
  };

  const handleSave = async () => {
    await UserService.updateAvatar(choosedImg);
    window.location.href = '/';
  };

  const handleLogout = async () => {
    await UserService.logout();
    signout(() => navigate('/login', { replace: true }));
  };

  return (
    <section className="profile">
      <div className="myImg">
        <ProgressiveImage
          src={avatar}
          placeholderSrc={placeholderSrc}
          className="avatar"
        />
        <h1>{name}</h1>
      </div>
      <div className="otherImg">
        {images.map((img) => (
          <ProgressiveImage
            key={img}
            src={`/avatars/${img}`}
            placeholderSrc={placeholderSrc}
            className={`avatar ${choosedImg === img ? 'selected' : ''}`}
            alt={`Avatar ${img}`}
            onClick={() => handleClick(img)}
          />
        ))}
      </div>
      <button
        className="btn"
        onClick={handleSave}
        style={{ marginBottom: '3rem' }}
      >
        Сохранить и продолжить
      </button>
      <button className="btn white" onClick={handleLogout}>
        Выйти
      </button>
    </section>
  );
};

export default Profile;

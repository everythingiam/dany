import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import UserService from '../API/UserService';
import { useFetching } from '../hooks/useFetching';

const Profile = () => {
  const [avatar, setAvatar] = useState('');
  const [name, setName] = useState('');
  const { signout } = useAuth();
  const navigate = useNavigate();
  const [choosedImg, setChoosedImg] = useState('');

  const images = ['1.png', '2.png', '3.png', '4.png', '5.png', 'default.png'];

  const [fetchUserData, isLoading] = useFetching(async () => {
    const response = await UserService.getUserData();
    const avatarPath = `/avatars/${response.data.avatar}`;
    setAvatar(avatarPath);
    setChoosedImg(response.data.avatar);
    setName(response.data.login);
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
    // Логика сохранения
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
        <img src={avatar} alt="User Avatar" className="avatar" />
        <h1>{name}</h1>
      </div>
      <div className="otherImg">
        {images.map((img) => (
          <img
            key={img}
            src={`/avatars/${img}`}
            alt={`Avatar ${img}`}
            className={`avatar ${choosedImg === img ? 'selected' : ''}`}
            onClick={() => handleClick(img)}
          />
        ))}
      </div>
      <button className="btn" onClick={handleSave} style={{marginBottom: '3rem'}}>
        Сохранить и продолжить
      </button>
      <button className="btn white" onClick={handleLogout}>
        Выйти
      </button>
    </section>
  );
};

export default Profile;

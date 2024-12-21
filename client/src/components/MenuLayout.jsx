import { Link, Outlet } from 'react-router-dom';
import Dany from '../assets/danylogo.svg';
import IconButton from '../UI/IconButton';
import '../styles/menu.scss';

const MenuLayout = () => {
  return (
    <>
      <Link to="/" className="dany-icon">
        <img src={Dany} alt="danyicon" />
      </Link>
      <div className="info">
        <IconButton icon={'question'} text="Правила" />
        <IconButton icon={'info'} text="Создание" />
      </div>

      <main>
        <Outlet />
      </main>
    </>
  );
};

export default MenuLayout;

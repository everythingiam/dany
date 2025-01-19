import W from '../assets/w.svg';
import S from '../assets/s.svg';
import F from '../assets/f.svg';
import Mouse from '../assets/mouse.svg';
import GamesService from '../API/GamesService';

const LayoutTip = ({ token, fetch }) => {
  const handleEndLayout = async () => {
    await GamesService.endLayout(token);
    await fetch();
  }

  return (
    <section className="layout-tip">
      <ul>
        <li>
          <img src={W} alt="" />
          Переместить карту наверх
        </li>
        <li>
          <img src={S} alt="" />
          Переместить карту вниз
        </li>
        <li>
          <img src={F} alt="" />
          Перевернуть карту
        </li>
        <li>
          <img src={Mouse} alt="" />
          Вращать карту
        </li>
      </ul>
      <button className='btn white' onClick={handleEndLayout}>Готово</button>
    </section>
  );
};

export default LayoutTip;

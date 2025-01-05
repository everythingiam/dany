import IconButton from '../UI/IconButton';
import Dany from '../assets/dany.svg';
import Person from '../assets/person.svg';

const TopBar = () => {
  return (
    <section className="top-bar">
      <div className="btns">
        <IconButton icon={'arrow-left'} />
        <IconButton icon={'question'} />
      </div>
      <div className="score">
        <img src={Dany} alt="" />
        <p className="klyakson">1 : 3</p>
        <img src={Person} alt="" />
      </div>
      <div className='phase'>
        <p className='klyakson'>выкладывание карт</p>
      </div>
    </section>
  );
};

export default TopBar;

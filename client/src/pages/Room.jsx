import '../styles/room.scss';
import TopBar from '../components/TopBar';
import PlayersList from '../components/PlayersList';
import CardsCanvas from '../components/CardsCanvas';
// import Tabs from '../components/Tabs';

const Room = () => {
  return (
    <section className='game-room'>
      <div className="left">
        <TopBar />
        <CardsCanvas />
        <PlayersList />
      </div>
      <div className="right">
        {/* <Tabs /> */}
      </div>
    </section>
  );
};

export default Room;

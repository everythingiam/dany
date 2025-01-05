import '../styles/room.scss';
import TopBar from '../components/TopBar';
import PlayersList from '../components/PlayersList';
import CardsCanvas from '../components/CardsCanvas';
import RoleTabs from '../components/RoleTabs';
import Chat from '../components/Chat';

const Room = () => {
  return (
    <main className='game-room'>
      <div className="left">
        <TopBar />
        <CardsCanvas />
        <PlayersList />
      </div>
      <div className="right">
        <Chat />
        <RoleTabs />
      </div>
    </main>
  );
};

export default Room;

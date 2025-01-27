import ProgressiveImage from '../components/ProgressiveImage';
import placeholderSrc from '../assets/white.svg';

const PlayerItem = ({ player, data }) => {
  
  return (
    <div>
      <ProgressiveImage
        src={`/avatars/${player.avatar}`}
        placeholderSrc={placeholderSrc}
        className={
          data.active_person === player.login
            ? 'active'
            : data.decisive_person === player.login
            ? 'decisive'
            : ''
        }
      />
      <p>{player.login}</p>
    </div>
  );
};

export default PlayerItem;

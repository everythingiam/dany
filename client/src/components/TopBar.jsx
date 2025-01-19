import { useState, useEffect } from 'react';
import IconButton from '../UI/IconButton';
import Dany from '../assets/dany.svg';
import GamesService from '../API/GamesService';
import Person from '../assets/person.svg';
import { useNavigate } from 'react-router-dom';
import { phaseTranslations } from '../utils/schemas';
import RulesModal from './RulesModal';

const TopBar = ({ data, token }) => {
  const navigate = useNavigate();
  const [rulesShow, setRulesShow] = useState(false);
  const [remainingTime, setRemainingTime] = useState(0);
  const phase_name = phaseTranslations[data.phase_name] || data.phase_name;

  // Форматируем оставшееся время в формате "минуты:секунды"
  const formatTime = (time) => {
    const minutes = Math.floor(time / 60);
    const seconds = time % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const startTimer = (initialTime) => {
    setRemainingTime(initialTime);

    if (window.timer) clearInterval(window.timer);

    window.timer = setInterval(async () => {
      setRemainingTime((prev) => {
        if (prev <= 1) {
          clearInterval(window.timer); 
          handleTimerEnd(); 
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleTimerEnd = async () => {
    await GamesService.getGameData(token);
  };

  useEffect(() => {
    if (!data.remaining_time) return;
    const timeParts = data.remaining_time.split(':');
    const seconds =
      parseInt(timeParts[0]) * 3600 +
      parseInt(timeParts[1]) * 60 +
      Math.floor(parseFloat(timeParts[2])); // Убираем дробную часть

    startTimer(seconds);
  }, [data.remaining_time]); 

  const handleLeave = async () => {
    navigate('/');
    await GamesService.leaveRoom(token);
  };

  return (
    <section className="top-bar">
      <div className="btns">
        <IconButton icon={'leave'} onClick={handleLeave} />
        <IconButton icon={'question'} onClick={() => setRulesShow(true)}/>
      </div>
      <div className="score">
        <img src={Dany} alt="" />
        <p className="klyakson">
          {data.dany_wins} : {data.person_wins}
        </p>
        <img src={Person} alt="" />
      </div>
      <div className="phase">
        <p className="klyakson">{phase_name}</p>
        <p className="klyakson">{formatTime(remainingTime)}</p>
      </div>
      <RulesModal show={rulesShow} onHide={() => setRulesShow(false)}/>
    </section>
  );
};

export default TopBar;

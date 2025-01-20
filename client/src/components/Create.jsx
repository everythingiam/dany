import { useState } from 'react';
import Modal from 'react-bootstrap/Modal';
import { useNavigate } from 'react-router-dom';
import GamesService from '../API/GamesService';

const Create = ({ show, onHide }) => {
  const navigate = useNavigate();
  const [speed, setSpeed] = useState('slow');
  const [number, setNumber] = useState(3);
  const [roomName, setRoomName] = useState('Комнатка');

  const increment = (e) => {
    e.preventDefault();
    if (number < 6) {
      setNumber(number + 1);
    }
  };

  const decrement = (e) => {
    e.preventDefault();
    if (number > 3) {
      setNumber(number - 1);
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const result = await GamesService.createRoom(number, speed, roomName);
    const gameToken = result.room_token;
    navigate(`/${gameToken}`);
  };

  const handleChooseSpeed = (speedValue, event) => {
    event.preventDefault();
    setSpeed(speedValue);
  };

  const handleRoomNameChange = (event) => {
    setRoomName(event.target.value);
  };

  return (
    <Modal
      show={show}
      onHide={onHide}
      size="lg"
      aria-labelledby="contained-modal-title-vcenter"
      centered
    >
      <h1>Создать комнату</h1>
      <button
        type="button"
        className="btn-close"
        aria-label="Close"
        onClick={onHide}
      ></button>

      <form className="create" onSubmit={handleSubmit}>
        <ul>
          <li>
            <label htmlFor="roomName">Название</label>
            <input
              id="roomName"
              type="text"
              placeholder="Название комнаты"
              value={roomName}
              onChange={handleRoomNameChange}
            />
          </li>
          <li className='row'>
            <div className='number'>
              <div className="label">Кол-во игроков</div>
              <div className="numberInput input-style">
                <button className='arrow' onClick={(event) => decrement(event)}>
                  &lsaquo;
                </button>
                {number}
                <button className='arrow' onClick={(event) => increment(event)}>
                  &rsaquo;
                </button>
              </div>
            </div>
            <div className='whole-width'>
              <div className="label">Скорость игры</div>
              <div className="speedInput input-style">
                <button
                  type="button"
                  className={`speed ${speed === 'slow' ? 'selected' : ''}`}
                  onClick={(event) => handleChooseSpeed('slow', event)}
                >
                  Медленная
                </button>
                <div className="line"></div>
                <button
                  type="button"
                  className={`speed ${speed === 'fast' ? 'selected' : ''}`}
                  onClick={(event) => handleChooseSpeed('fast', event)}
                >
                  Быстрая
                </button>
              </div>
            </div>
          </li>
          <li>
            <button className="btn" type="submit">
              Создать и перейти
            </button>
          </li>
        </ul>
      </form>
    </Modal>
  );
};

export default Create;

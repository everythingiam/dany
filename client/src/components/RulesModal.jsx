import Modal from 'react-bootstrap/Modal';
import Dany from '../assets/dany.svg';
import Person from '../assets/person.svg';
import R0 from '../assets/rules/rul0.png';
import R1 from '../assets/rules/rul1.png';
import R2 from '../assets/rules/rul2.png';
import R3 from '../assets/rules/rul3.png';
import R4 from '../assets/rules/rul4.png';
import R5 from '../assets/rules/rul5.png';
import R6 from '../assets/rules/rul6.png';

const RulesModal = ({ show, onHide }) => {
  return (
    <Modal
      show={show}
      onHide={onHide}
      size="lg"
      aria-labelledby="contained-modal-title-vcenter"
      centered
      className="rules"
    >
      <h1>Правила</h1>
      <button
        type="button"
        className="btn-close"
        aria-label="Close"
        onClick={onHide}
      ></button>

      <div className="roles">
        <div className="role">
          <img src={Dany} alt="" />
          <p>
            Если вы Дэни, то ваша задача — всеми силами мешать другим личностям
            и ни в коем случае не выдавать себя. Например, неправильно
            показывать слово, неверно отвечать, запутывать других в чате.
          </p>
        </div>
        <div className="role">
          <img src={Person} alt="" />
          <p>
            Если вы альтернативная личность Дэни, то вы должны безошибочно
            угадывать то, что другие личности пытаются сказать.
          </p>
        </div>
      </div>
      <h2>Ход игры:</h2>
      <div className="hodi">
        <div className="hod">
          <p>
            0. Все игроки являются альтернативными личностями мальчика, но один
            из игроков случайным образом становится <strong>Дэни</strong>.
          </p>
          <img src={R0} alt="" />
        </div>
        <div className="hod">
          <p>
            1. Каждый раунд выдаются 5 слов, одно из которых тайно выдаётся{' '}
            <strong>Активной личности</strong>.
          </p>
          <img src={R1} alt="" />
        </div>
        <div className="hod">
          <p>
            2. <strong>Активная личность</strong> пытается показать другим это
            слово с помощью случайно выданных карт воспоминаний.
          </p>
          <img src={R2} alt="" />
        </div>
        <div className="hod">
          <p>3. Все обсуждают, какое это может быть слово.</p>

          <img src={R3} alt="" />
        </div>
        <div className="hod">
          <p>
            4. После обсуждения <strong>решающая личность</strong>{' '}
            самостоятельно делает решение.
          </p>
          <img src={R4} alt="" />
        </div>
        <div className="hod">
          <p>
            5. Если угадала - то +1 балл команде <strong>Личностей</strong>,
            если нет, то +1 балл команде <strong>Дэни</strong>.
          </p>
          <img src={R5} alt="" />
        </div>
        <div className="hod">
          <p>
            6. Роли <strong>активной</strong> и{' '}
            <strong>решающей личностей</strong> меняются по кругу.
          </p>
          <img src={R6} alt="" />
        </div>
      </div>
      <p>
        <a
          href="https://gaga.ru/gaga/files/pdf/rules/ru/5252.pdf?clckid=c13f7084"
          target="_blank"
        >
          Оригинальные правила и подробнее об игре
        </a>{' '}
        →
      </p>
    </Modal>
  );
};

export default RulesModal;

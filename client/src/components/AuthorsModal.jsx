import Modal from 'react-bootstrap/Modal';

const AuthorsModal = ({ show, onHide }) => {
  return (
    <Modal
      show={show}
      onHide={onHide}
      size="lg"
      aria-labelledby="contained-modal-title-vcenter"
      centered
    >
      <h1>Создание приложения</h1>
      <button
        type="button"
        className="btn-close"
        aria-label="Close"
        onClick={onHide}
      ></button>
      <p>Проект был разработан в рамках курса</p>
      <p>
        <strong>«Базы данных для игровых приложений»</strong>
      </p>
      <p>от Университета ИТМО</p>
      <p style={{ marginTop: '2rem' }}>
        <strong>Фронтенд-разработчик:</strong>{' '}
        <a href="https://t.me/alinachnnl" target="_blank">
          Михайлова Алина
        </a>{' '}
        →
      </p>
      <p>
        <strong>Бэкенд-разработчик:</strong>{' '}
        <a href="https://t.me/alinachnnl" target="_blank">
          Михайлова Алина
        </a>{' '}
        →
      </p>
      <p>
        <strong>Дизайнер:</strong>{' '}
        <a href="https://t.me/alinachnnl" target="_blank">
          Михайлова Алина
        </a>{' '}
        →
      </p>
      <p style={{ marginTop: '2rem' }}>2025</p>
    </Modal>
  );
};

export default AuthorsModal;

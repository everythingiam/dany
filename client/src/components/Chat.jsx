import { useEffect, useRef, useState } from 'react';

const Chat = ({ token, login }) => {
  const [messages, setMessages] = useState([]);
  const [value, setValue] = useState('');
  const socket = useRef();

  useEffect(() => {
    socket.current = new WebSocket('ws://localhost:4000/');

    socket.current.onopen = () => {
      socket.current.send(
        JSON.stringify({
          id: token,
          login,
          method: 'connection',
        })
      );
    };

    socket.current.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      setMessages((prev) => [...prev, msg]);
    };

    return () => {
      socket.current.close();
    };
  }, []);

  const sendMessage = async (event) => {
    event.preventDefault();
    const message = {
      login,
      message: value,
      id: token,
      method: 'message',
    };
    socket.current.send(JSON.stringify(message));
    setValue('');
  };

  return (
    <section className="chat">
      <div className="cont">
        <div className="messages">
          {messages.map((msg, index) => (
            <div key={index}>
              {msg.method === 'connection' && (
                <p>
                  Пользователь <strong>{msg.login}</strong> подключился
                </p>
              )}
              {msg.method === 'message' && (
                <p>
                  <strong>{msg.login}</strong>: {msg.message}
                </p>
              )}
            </div>
          ))}
        </div>
        <form>
          <input
            type="text"
            placeholder="Введите сообщение"
            value={value}
            onChange={(e) => setValue(e.target.value)}
          />
          <button className="btn" onClick={sendMessage}>
            Отправить
          </button>
        </form>
        <span>Чат</span>
      </div>
    </section>
  );
};

export default Chat;

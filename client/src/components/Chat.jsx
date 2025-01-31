import { useEffect, useRef, useState } from 'react';
import config from "..config.js";

const Chat = ({ token, login, data }) => {
  const [messages, setMessages] = useState([]);
  const [value, setValue] = useState('');
  const socket = useRef(null); 
  const messagesEndRef = useRef(); 

  useEffect(() => {
    socket.current = new WebSocket(config.WS_URL);

    socket.current.onopen = () => {
      socket.current.send(
        JSON.stringify({
          id: token,
          login,
          method: 'chatConnection',
        })
      );
    };

    socket.current.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      setMessages((prev) => [...prev, msg]);
    };

    return () => {
      if (socket.current) {
        socket.current.close();
      }
    };
  }, [token, login]);

  useEffect(() => {
    let systemMessage = '';

    switch (data.phase_name) {
      case 'layout': {
        const word = data.decided_word;
        if (word === null) {
          systemMessage = `${data.active_person} изображает слово`;
        } else if (word === 'missed') {
          systemMessage = `Решения не было! Правильным словом было '${data.prev_active_word}'. ${data.active_person} изображает слово`;
        } else {
          systemMessage = `Было выбрано слово '${word}'. Правильным словом было '${data.prev_active_word}'. ${data.active_person} изображает слово`;
        }
        break;
      }
      case 'discussion':
        systemMessage = `${data.active_person} изобразил слово. Обсуждайте! Решение за ${data.decisive_person}`;
        break;
      case 'decision':
        systemMessage = `${data.decisive_person} решает...`;
        break;
      case 'waiting':
        systemMessage = `Комната создана!`;
        break;
      default:
        break;
    }

    if (systemMessage) {
      const phaseMessage = {
        login: 'Система',
        message: systemMessage,
        id: token,
        method: 'message',
      };
      setMessages((prev) => [...prev, phaseMessage]);
    }
  }, [
    data.phase_name,
    data.decided_word,
    data.active_person,
    data.decisive_person,
    token,
  ]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = async (event) => {
    event.preventDefault();
    if (!socket.current) return; 

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
          {messages.map((msg, index) => {
            if (msg.method === 'draw' || msg.method === 'connection') {
              return null;
            }
            return (
              <div key={index}>
                {msg.method === 'chatConnection' && (
                  <p>
                    Пользователь <strong>{msg.login}</strong> подключился
                  </p>
                )}
                {msg.method === 'message' && (
                  <p>
                    <strong
                      style={msg.login === 'Система' ? { color: 'red' } : {}}
                    >
                      {msg.login}
                    </strong>
                    :{' '}
                    {msg.login === 'Система' ? (
                      <strong>{msg.message}</strong>
                    ) : (
                      msg.message
                    )}
                  </p>
                )}
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>

        <form>
          <input
            type="text"
            placeholder="Введите сообщение"
            value={value}
            onChange={(e) => setValue(e.target.value)}
            disabled={data.active_person === login}
          />
          <button
            className="btn"
            onClick={sendMessage}
            disabled={data.active_person === login}
          >
            Отправить
          </button>
        </form>
        <span>Чат</span>
      </div>
    </section>
  );
};

export default Chat;

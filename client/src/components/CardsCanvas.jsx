import { useRef, useEffect, useState } from 'react';
import CanvasState from '../cards/CanvasState';
import { observer } from 'mobx-react-lite';

const CardsCanvas = observer(({ token, data, login }) => {
  const [flag, setFlag] = useState(false);
  const [canvasReady, setCanvasReady] = useState(false);
  const canvasRef = useRef();
  const [start, setStart] = useState(false);

  useEffect(() => {
    const initCanvas = async () => {
      await CanvasState.init(canvasRef.current);
      setCanvasReady(true);
    };

    initCanvas();

    return () => {
      const cleanUp = async () => {
        if (canvasReady)
        await CanvasState.clean();
      };
      cleanUp();
    };
  }, [start]);

  useEffect(() => {
    if (data.phase_name === 'layout') {
      setFlag(true);
    } else if (flag) {
      setFlag(false);
    }

    if (data.phase_name !== 'layout' && canvasReady) CanvasState.disable();

    if (data.phase_name !== 'waiting' && !start) {
      setStart(true);
    }
  }, [data.phase_name]);

  useEffect(() => {
    
    const updateCardsToCanvas = async () => {
      await CanvasState.removeAllCards();
      console.log('карты добавляются или нет алё');

      const cards = data.active_cards.map(
        (card) => `/static/cards/${card.image_path}`
      );

      for (const src of cards) {
        await CanvasState.addCard(src);
      }

      if (canvasReady) {
        CanvasState.disable();
        if (data.active_person === login && data.phase_name === 'layout') {
          CanvasState.enable();
        }
        setStart(false);
      }
    };

    if (flag) {
      updateCardsToCanvas();
    }
    console.log(start);

  }, [flag]);

  useEffect(() => {
    const socket = new WebSocket('ws://localhost:4000/');
    CanvasState.setSocket(socket);
    CanvasState.setSessionId(token);

    socket.onopen = () => {
      socket.send(
        JSON.stringify({
          id: token,
          method: 'connection',
        })
      );
    };

    socket.onmessage = (event) => {
      let msg = JSON.parse(event.data);
      switch (msg.method) {
        case 'connection':
          console.log('пользователь присоединился');
          break;
        case 'draw':
          drawHandler(msg);
          break;
      }
    };

    if (data.phase_name !== 'waiting' && !start) {
      console.log(start);
      console.log(data.phase_name);
      setStart(true);
      console.log(start);
    }
  }, []);

  const drawHandler = (msg) => {
    const coords = msg.coords;
    CanvasState.setCard(coords);
  };

  return <canvas width="750" height="370" ref={canvasRef} />;
});

export default CardsCanvas;

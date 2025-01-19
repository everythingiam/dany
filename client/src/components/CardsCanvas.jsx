import { useRef, useEffect, useState } from 'react';
import CanvasState from '../cards/CanvasState';
import { observer } from 'mobx-react-lite';

const CardsCanvas = observer(({ token, data, login }) => {
  const [flag, setFlag] = useState(false);
  const [cardsReady, setCardsReady] = useState(false);
  const canvasRef = useRef();

  useEffect(() => {
    if (data.phase_name === 'layout') {
      setFlag(true);
    } else if (flag) {
      setFlag(false);
    }

    if (data.phase_name !== 'layout') CanvasState.disable();
  }, [data.phase_name]);

  useEffect(() => {
    const initCanvas = async () => {
      await CanvasState.init(canvasRef.current);
      await CanvasState.syncCards();
    };

    initCanvas();

    return () => {
      const cleanUp = async () => {
        await CanvasState.clean();
      };
      cleanUp();
    };
  }, []);

  useEffect(() => {
    const updateCardsToCanvas = async () => {
      await CanvasState.removeAllCards();

      const cards = data.active_cards.map(
        (card) => `/static/cards/${card.image_path}`
      );

      for (const src of cards) {
        await CanvasState.addCard(src);
      }
      setCardsReady(true);
      
      CanvasState.disable();

      if (data.active_person === login && data.phase_name === 'layout') {
        CanvasState.enable();
      }
    };

    if (flag) {
      updateCardsToCanvas();
    }
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
  }, []);

  const drawHandler = (msg) => {
    const coords = msg.coords;
    CanvasState.setCard(coords);
  };

  return <canvas width="750" height="370" ref={canvasRef} />;
});

export default CardsCanvas;

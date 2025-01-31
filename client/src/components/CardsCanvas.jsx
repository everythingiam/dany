import { useRef, useEffect, useState } from 'react';
import CanvasState from '../cards/canvasState';
import { observer } from 'mobx-react-lite';
import config from "..config.js";

const CardsCanvas = observer(({ token, data, login }) => {
  const [flag, setFlag] = useState(false);
  const [canvasReady, setCanvasReady] = useState(false);
  const canvasRef = useRef();

  useEffect(() => {
    const initCanvas = async () => {
      await CanvasState.init(canvasRef.current);
      await sync();

      setCanvasReady(true);
    };
    let timeout;

    const updateFlag = () => {
      if (data.decided_word != null) {
        setFlag(false);
      }
    };

    timeout = setTimeout(() => updateFlag(), 200);

    initCanvas();

    return () => {
      CanvasState.clean();
      clearTimeout(timeout);
    };
  }, []);

  useEffect(() => {
    let timeout;

    if (data.phase_name === 'layout') {
      timeout = setTimeout(() => setFlag(true), 100);
    } else if (flag) {
      timeout = setTimeout(() => setFlag(false), 100);
    }

    if (data.phase_name !== 'layout' && canvasReady) {
      CanvasState.disable();
    }

    return () => {
      clearTimeout(timeout);
    };
  }, [data.phase_name]);

  useEffect(() => {
    let timeout;
    const update = async () => {
      if (flag) {
        setFlag(false);
        await updateCardsToCanvas();
      }
    };
    timeout = setTimeout(() => update(), 200);
    return () => {
      clearTimeout(timeout);
    };
  }, [flag]);

  useEffect(() => {
    const socket = new WebSocket(config.WS_URL);
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
      const msg = JSON.parse(event.data);
      if (msg.method === 'draw') {
        drawHandler(msg);
      }
    };

    return () => {
      socket.close();
    };
  }, [token]);

  const drawHandler = (msg) => {
    CanvasState.setCard(msg.coords);
  };

  const updateCardsToCanvas = async () => {
    await CanvasState.removeAllCards();

    const cardPaths = data.active_cards.map(
      (card) => `/static/cards/${card.image_path}`
    );

    for (const src of cardPaths) {
      await CanvasState.addCard(src);
    }

    if (data.active_person === login && data.phase_name === 'layout') {
      CanvasState.enable();
    } else {
      CanvasState.disable();
    }
  };

  const sync = async () => {
    await CanvasState.syncCards();

    if (data.active_person === login && data.phase_name === 'layout') {
      CanvasState.enable();
    } else {
      CanvasState.disable();
    }
  }

  useEffect(() => {
    if (canvasRef.current && data.active_person === login) {
      const canvas = canvasRef.current;
  
      canvas.style.transition = 'opacity 0.5s';
      canvas.style.opacity = 0.4;
    
      const timeout = setTimeout(() => {
        canvas.style.opacity = 1;
      }, 2000);
  
      return () => clearTimeout(timeout);
    }
  }, [flag]);

  return <canvas width="750" height="370" ref={canvasRef} />;
});

export default CardsCanvas;

import { useRef, useEffect } from 'react';
import canvasState from '../cards/canvasState';
import { observer } from 'mobx-react-lite';
// import Card1 from '../assets/cards/1.png';
// import Card2 from '../assets/cards/2.png';
// import Card3 from '../assets/cards/3.png';
// import Card4 from '../assets/cards/4.png';
// import Card5 from '../assets/cards/5.png';
// import Card6 from '../assets/cards/6.png';
 
const CardsCanvas = observer(({ token, data, flag }) => {
  const canvasRef = useRef();
 
  useEffect(() => {
    canvasState.setCanvas(canvasRef.current);
 
    const updateCardsToCanvas = async () => {
      await canvasState.removeAllCards();
 
      // const cards = [Card1, Card2, Card3, Card4, Card5, Card6];
      const cards = data.active_cards.map(
        (card) => `/static/cards/${card.image_path}`
      );
 
      console.log(cards);
      for (const src of cards) {
        await canvasState.addCard(src);
      }
    };
 
    updateCardsToCanvas();
 
    return () => {
      canvasState.removeEventHandlers();
    };
  }, [flag]);
 
  useEffect(() => {
    const socket = new WebSocket('ws://localhost:4000/');
    canvasState.setSocket(socket);
    canvasState.setSessionId(token);
    console.log(socket);
 
    socket.onopen = () => {
      console.log('Подключение установлено');
      socket.send(
        JSON.stringify({
          id: token,
          method: 'connection',
        })
      );
    
      // Отправить текущее состояние всех карт
      const allCards = this.canvas.getObjects().map((card) => ({
        top: card.top,
        left: card.left,
        angle: card.angle,
        zIndex: this.canvas.getObjects().indexOf(card),
        isFlipped: card.isFlipped,
        cardId: card.cardId,
      }));
      socket.send(
        JSON.stringify({
          method: 'sync',
          id: token,
          cards: allCards,
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
          console.log(msg);
          drawHandler(msg);
          break;
      }
    };
  }, []);
 
  const drawHandler = (msg) => {
    const coords = msg.coords;
    canvasState.setCards(coords);
    console.log(coords);
  };
 
  return <canvas width="750" height="370" ref={canvasRef} />;
});
 
export default CardsCanvas;
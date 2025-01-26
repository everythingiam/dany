import { makeAutoObservable } from 'mobx';
import * as fabric from 'fabric';
import { CardItem } from './cardItem';

class CanvasState {
  canvas = null;
  socket = null;
  sessionId = null;

  constructor() {
    makeAutoObservable(this);
    this.canvas = null;
  }

  async init(canvasRef) {
    if (this.canvas) {
      return;
    }

    this.canvas = new fabric.Canvas(canvasRef, {
      preserveObjectStacking: true,
      selection: false,
    });

    this.#listen();
  }

  async addCard(src, id) {
    if (this.canvas.getObjects().length >= 7) {
      console.warn('Canvas is full.');
      return;
    }

    // console.log('adding card:', src);

    const card = await new CardItem(src, id);
    this.canvas.add(card);
    this.canvas.setActiveObject(card);

    this.#saveCardsToLocalStorage();
    this.#sendActiveObjectData(card);
  }

  setSocket(socket) {
    this.socket = socket;
  }

  setSessionId(sessionId) {
    this.sessionId = sessionId;
  }

  setCard(coords) {
    const existingCard = this.canvas
      .getObjects()
      .find((obj) => obj.frontImage === coords.frontImage);

    if (!existingCard) {
      return;
    }

    this.#setCoordsOnCard(existingCard, coords);

    this.canvas.renderAll();
    this.#saveCardsToLocalStorage();
  }

  async syncCards() {
    const storedCards = JSON.parse(localStorage.getItem('canvasCards')) || [];

    for (const cardData of storedCards) {
      const existingCard = this.canvas
        .getObjects()
        .find((obj) => obj.name === cardData.frontImage);

      if (existingCard) {
        existingCard.set({
          left: cardData.left,
          top: cardData.top,
          angle: cardData.angle || 0,
        });
      } else {
        const card = await new CardItem(cardData.frontImage);
        this.canvas.add(card);
        this.#setCoordsOnCard(card, cardData);
      }
    }

    this.canvas.renderAll();
  }

  async removeAllCards() {
    if (!this.canvas) return;

    this.canvas.remove(...this.canvas.getObjects());
    localStorage.removeItem('canvasCards');
  }

  async clean() {
    this.#removeEventHandlers();
    localStorage.clear();
    await this.removeAllCards();
    this.#disposeCanvas();
  }

  disable() {
    this.canvas.forEachObject(function (o) {
      o.selectable = false;
      o.evented = false;
    });
    this.#removeEventHandlers();
  }

  enable() {
    this.canvas.forEachObject(function (o) {
      o.selectable = true;
      o.evented = true;
    });
    this.#listen();
  }

  #listen() {
    this.canvas.on('mouse:wheel', this.#handleWheel);
    this.canvas.on('object:modified', this.#handleObjectModified);
    this.canvas.on('object:selected', this.#handleObjectSelected);

    this.canvas.on('mouse:down', this.#handleMouseDown);
    this.canvas.on('mouse:move', this.#handleMouseMove);
    this.canvas.on('mouse:up', this.#handleMouseUp);

    window.addEventListener('keydown', this.#handleKeyPress);
  }

  #handleMouseDown = () => {
    this.isMouseDown = true;
  };

  #handleMouseMove = () => {
    if (!this.isMouseDown) return;

    const activeObject = this.canvas.getActiveObject();
    if (activeObject) {
      this.#sendActiveObjectData(activeObject);
    }
  };

  #handleMouseUp = () => {
    this.isMouseDown = false;
  };

  #handleWheel = (opt) => {
    const event = opt.e;
    event.preventDefault();
    const activeObject = this.canvas.getActiveObject();
    if (!activeObject) return;

    const delta = Math.sign(event.deltaY);
    activeObject.angle += delta * 7;
    this.canvas.renderAll();

    this.#sendActiveObjectData(activeObject);
  };

  #handleObjectModified = (event) => {
    const modifiedObject = event.target;
    this.#sendActiveObjectData(modifiedObject);
  };

  #handleObjectSelected = (event) => {
    const activeObject = event.target;
    this.#sendActiveObjectData(activeObject);
  };

  #saveCardsToLocalStorage() {
    const cards = this.canvas.getObjects().map((obj, zIndex) => ({
      id: obj.id,
      frontImage: obj.frontImage,
      backImage: obj.backImage,
      top: obj.top,
      left: obj.left,
      angle: obj.angle,
      isFlipped: obj.isFlipped,
      zIndex,
    }));

    localStorage.setItem('canvasCards', JSON.stringify(cards));
  }

  #setCoordsOnCard(card, coords) {
    card.set({
      top: coords.top,
      left: coords.left,
      angle: coords.angle,
    });

    if (card.isFlipped !== coords.isFlipped) {
      this.#replaceImage(card);
    }

    const currentZIndex = this.canvas.getObjects().indexOf(card);
    if (coords.zIndex > currentZIndex) {
      for (let i = coords.zIndex; i > currentZIndex; i--) {
        this.#bringForward(card);
      }
    }
    if (coords.zIndex < currentZIndex) {
      for (let i = coords.zIndex; i < currentZIndex; i++) {
        this.#sendBackward(card);
      }
    }
    if (coords.zIndex === currentZIndex) {
      return;
    }
  }

  #sendActiveObjectData = (activeObject) => {
    if (!activeObject) return;

    const top = activeObject.top;
    const left = activeObject.left;
    const angle = activeObject.angle;
    const zIndex = this.canvas.getObjects().indexOf(activeObject);
    const isFlipped = activeObject.isFlipped;
    const frontImage = activeObject.frontImage;

    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      console.warn('WebSocket is not ready. Skipping send.');
      return;
    }

    this.socket.send(
      JSON.stringify({
        method: 'draw',
        id: this.sessionId,
        coords: {
          top,
          left,
          angle,
          zIndex,
          isFlipped,
          frontImage,
        },
      })
    );
  };

  #handleKeyPress = (event) => {
    const activeObject = this.canvas.getActiveObject();
    if (!activeObject || this.canvas.wrapperEl?.classList.contains('disabled'))
      return;

    switch (event.key.toLowerCase()) {
      case 'd':
      case 'в':
        this.#replaceImage(activeObject);
        break;
      case 'w':
      case 'ц':
        this.#bringForward(activeObject);
        break;
      case 's':
      case 'ы':
        this.#sendBackward(activeObject);
        break;
      default:
        break;
    }

    this.#sendActiveObjectData(activeObject);
  };

  #replaceImage(activeObject) {
    const isFlipped = activeObject.isFlipped;
    const newImageSrc = isFlipped
      ? activeObject.frontImage
      : activeObject.backImage;

    activeObject._element.src = newImageSrc;
    activeObject.isFlipped = !isFlipped;
    activeObject._element.onload = () => this.canvas.renderAll();
  }

  #bringForward(activeObject) {
    if (activeObject) {
      this.canvas.bringObjectForward(activeObject, true);
      this.canvas.renderAll();
    }
  }

  #sendBackward(activeObject) {
    if (activeObject) {
      this.canvas.sendObjectBackwards(activeObject, true);
      // this.canvas.sendObjectToBack(activeObject, true);
      this.canvas.renderAll();
    }
  }

  #disposeCanvas() {
    this.canvas.dispose();
  }

  #removeEventHandlers() {
    this.canvas.off('mouse:wheel', this.#handleWheel);
    this.canvas.off('object:modified', this.#handleObjectModified);
    this.canvas.off('object:selected', this.#handleObjectSelected);

    window.removeEventListener('keydown', this.#handleKeyPress);
  }
}

export default new CanvasState();

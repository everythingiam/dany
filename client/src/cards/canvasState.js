import { makeAutoObservable } from 'mobx';
import * as fabric from 'fabric';
import { cardItem } from './cardItem';
 
class CanvasState {
  canvas = null;
  socket = null;
  sessionId = null;
  observer = null;
  constructor() {
    makeAutoObservable(this);
  }
 
  setCanvas(canvasRef) {
    this.canvas = new fabric.Canvas(canvasRef, {
      preserveObjectStacking: true,
      selection: false,
    });
 
    this.listen();
  }
 
  async addCard(src, id) {
    if (!this.canvas) return;
 
    const card = await new cardItem(src, id);
    this.canvas.add(card);
    this.canvas.setActiveObject(card);
 
    this.sendActiveObjectData(card);
  }
 
  setSocket(socket) {
    this.socket = socket;
  }
 
  setSessionId(sessionId) {
    this.sessionId = sessionId;
  }
 
  async removeAllCards() {
    if (!this.canvas) return;
 
    this.canvas.remove(...this.canvas.getObjects());
  }
 
  listen() {
    if (this.canvas) {
      this.canvas.on('mouse:wheel', this.handleWheel);
      this.canvas.on('object:modified', this.handleObjectModified);
      this.canvas.on('object:selected', this.handleObjectSelected);
 
      this.canvas.on('mouse:down', this.handleMouseDown);
      this.canvas.on('mouse:move', this.handleMouseMove);
      this.canvas.on('mouse:up', this.handleMouseUp);
    }
 
    window.addEventListener('keydown', this.handleKeyPress);
 
    if (this.canvas) {
      this.observer = new MutationObserver(this.handleDisabledState);
      this.observer.observe(this.canvas.wrapperEl, {
        attributes: true,
        attributeFilter: ['class'],
      });
    }
  }
 
  handleMouseDown = () => {
    this.isMouseDown = true;
  };
 
  handleMouseMove = () => {
    if (!this.isMouseDown || !this.canvas) return;
 
    const activeObject = this.canvas.getActiveObject();
    if (activeObject) {
      this.sendActiveObjectData(activeObject);
    }
  };
 
  handleMouseUp = () => {
    this.isMouseDown = false;
  };
 
  handleWheel = (opt) => {
    if (!this.canvas) return;
 
    const event = opt.e;
    event.preventDefault();
    const activeObject = this.canvas.getActiveObject();
    if (!activeObject) return;
 
    const delta = Math.sign(event.deltaY);
    activeObject.angle += delta * 7;
    this.canvas.renderAll();
 
    this.sendActiveObjectData(activeObject);
  };
 
  handleObjectModified = (event) => {
    const modifiedObject = event.target;
    this.sendActiveObjectData(modifiedObject);
  };
 
  handleObjectSelected = (event) => {
    const activeObject = event.target;
    this.sendActiveObjectData(activeObject);
  };
 
  sendActiveObjectData = (activeObject) => {
    if (!activeObject) return;
 
    const top = activeObject.top;
    const left = activeObject.left;
    const angle = activeObject.angle;
    const zIndex = this.canvas.getObjects().indexOf(activeObject);
    const isFlipped = activeObject.isFlipped;
    const cardId = activeObject.cardId;
 
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
          cardId,
        },
      })
    );
 
    // console.log({
    //   top,
    //   left,
    //   angle,
    //   zIndex,
    //   isFlipped,
    //   sessionId: this.sessionId,
    //   socket: this. socket
    // });
  };
 
  setCards(coords) {
    if (!this.canvas) return;
 
    const existingCard = this.canvas
      .getObjects()
      .find((obj) => obj.cardId === coords.cardId);

      console.log(existingCard);
 
    existingCard.set({
      top: coords.top,
      left: coords.left,
      angle: coords.angle,
    });
 
    if (existingCard.isFlipped !== coords.isFlipped) {
      this.replaceImage(existingCard);
    }
 
    const currentZIndex = this.canvas.getObjects().indexOf(existingCard);
    if (currentZIndex < coords.zIndex) {
      for (let i = currentZIndex; i < coords.zIndex; i++) {
        this.bringForward(existingCard);
      }
    } else if (currentZIndex > coords.zIndex) {
      for (let i = currentZIndex; i > coords.zIndex; i--) {
        this.sendBackward(existingCard);
      }
    }
 
    this.canvas.renderAll();
  }
 
  handleKeyPress = (event) => {
    if (!this.canvas) return;
 
    const activeObject = this.canvas.getActiveObject();
    if (!activeObject || this.canvas.wrapperEl?.classList.contains('disabled'))
      return;
 
    switch (event.key.toLowerCase()) {
      case 'd':
      case 'в':
        this.replaceImage(activeObject);
        break;
      case 'w':
      case 'ц':
        this.bringForward(activeObject);
        break;
      case 's':
      case 'ы':
        this.sendBackward(activeObject);
        break;
      default:
        break;
    }
 
    this.sendActiveObjectData(activeObject);
  };
 
  handleDisabledState = () => {
    if (!this.canvas || !this.canvas.wrapperEl) return;
 
    if (this.canvas.wrapperEl.classList.contains('disabled')) {
      this.canvas.discardActiveObject();
      this.canvas.renderAll();
    }
  };
 
  replaceImage(activeObject) {
    const isFlipped = activeObject.isFlipped;
    const newImageSrc = isFlipped
      ? activeObject.frontImage
      : activeObject.backImage;
 
    activeObject._element.src = newImageSrc;
    activeObject.isFlipped = !isFlipped;
    activeObject._element.onload = () => this.canvas.renderAll();
  }
 
  bringForward(activeObject) {
    if (activeObject) {
      this.canvas.bringObjectForward(activeObject, true);
      this.canvas.renderAll();
    }
  }
 
  sendBackward(activeObject) {
    if (activeObject) {
      this.canvas.sendObjectBackwards(activeObject, true);
      this.canvas.renderAll();
    }
  }
 
  removeEventHandlers() {
    if (this.canvas) {
      this.canvas.off('mouse:wheel', this.handleWheel);
      this.canvas.off('object:modified', this.handleObjectModified);
      this.canvas.off('object:selected', this.handleObjectSelected);
    }
 
    window.removeEventListener('keydown', this.handleKeyPress);
 
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
 
    if (this.canvas) {
      this.canvas.dispose();
      this.canvas = null;
    }
  }
}
 
export default new CanvasState();
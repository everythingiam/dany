import Back from '../assets/cards/back.png';
import * as fabric from 'fabric';
 
let cardCounter = 1;
 
export class cardItem {
  constructor(src) {
    return new Promise((resolve) => {
      const img = new Image();
      const cardId = cardCounter;
      cardCounter++;
 
      img.onload = () => {
        const imgObj = new fabric.Image(img, {
          centeredRotation: true,
          centeredScaling: true,
          scaleX: 0.3,
          scaleY: 0.3,
          left: 140,
          top: 100,
          angle: 0,
          isFlipped: false,
          frontImage: src,
          backImage: Back,
          originX: 'center',
          originY: 'center',
          transparentCorners: false,
          cornerColor: '#375BA8',
          cornerStyle: 'circle',
        });
 
        imgObj.setControlsVisibility({
          ml: false,
          mt: false,
          mr: false,
          mb: false,
          tl: false,
          tr: false,
          bl: false,
          br: false,
          mtr: false,
        });
 
        imgObj.lockScalingX = true;
        imgObj.lockScalingY = true;
        imgObj.hasRotatingPoint = true;
        imgObj.cardId = cardId;
 
        resolve(imgObj);
      };
 
      img.src = src;
    });
  }
}
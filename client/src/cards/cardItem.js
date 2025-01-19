import Back from '../assets/cards/back.png';
import * as fabric from 'fabric';

export class CardItem {
  static cardPositions = [
    { left: 116, top: 116, angle: -8 },
    { left: 188, top: 130, angle: 5 },
    { left: 307, top: 214, angle: -5 },
    { left: 402, top: 141, angle: 0 },
    { left: 521, top: 151, angle: -9 },
    { left: 603, top: 238, angle: 5},
    { left: 655, top: 135, angle: -5 },
  ];

  static positionIndex = 0;

  constructor(src) {
    return new Promise((resolve) => {
      const img = new Image();

      img.onload = () => {
        const position =
          CardItem.cardPositions[
            CardItem.positionIndex % CardItem.cardPositions.length
          ];
        CardItem.positionIndex++;

        const imgObj = new fabric.Image(img, {
          centeredRotation: true,
          centeredScaling: true,
          scaleX: 0.3,
          scaleY: 0.3,
          left: position.left,
          top: position.top,
          angle: position.angle,
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

        resolve(imgObj);
      };

      img.src = src;
    });
  }
}

import { useRef, useEffect } from 'react';
import * as fabric from 'fabric';
import Card1 from '../assets/cards/1.png';
import Card2 from '../assets/cards/2.png';
import Card3 from '../assets/cards/3.png';
import Card4 from '../assets/cards/4.png';
import Card5 from '../assets/cards/5.png';
import Card6 from '../assets/cards/6.png';
import Back from '../assets/cards/back.png';

function App() {
	const canvasRef = useRef();
	const canvasInstance = useRef(null);

	useEffect(() => {
		const canvas = new fabric.Canvas(canvasRef.current, {
			preserveObjectStacking: true,
			selection: false, 
		});
		canvasInstance.current = canvas;

		[Card1, Card2, Card3, Card4, Card5, Card6].forEach((src) => {
			handleAddImage(src);
		});

		const handleKeyPress = (event) => {
			const activeObject = canvas.getActiveObject();
			if (!activeObject) return;

			if (event.key.toLowerCase() === 'd' || event.key.toLowerCase() === 'в') {
				replaceImage(activeObject);
			}

			if (event.key.toLowerCase() === 'w' || event.key.toLowerCase() === 'ц') {
				bringForward(activeObject);
			}

			if (event.key.toLowerCase() === 's' || event.key.toLowerCase() === 'ы') {
				sendBackward(activeObject);
			}
		};

		const handleWheel = (opt) => {
			const event = opt.e;
			event.preventDefault();

			const activeObject = canvas.getActiveObject();
			if (!activeObject) return;

			const delta = Math.sign(event.deltaY);

			activeObject.angle += delta * 7;
			canvas.renderAll();
		};

		canvas.on('mouse:wheel', handleWheel);

		window.addEventListener('keydown', handleKeyPress);

		return () => {
			window.removeEventListener('keydown', handleKeyPress);
			canvas.dispose();
		};
	}, []);

	const handleAddImage = (src) => {
		const canvas = canvasInstance.current;
		if (!canvas) return;

		const img = new Image();

		img.onload = () => {
			const randomLeft = Math.random() * (canvas.width - img.width / 2);
			const randomTop = Math.random() * (canvas.height - img.height / 2);

			const imgObj = new fabric.Image(img, {
				centeredRotation: true,
				centeredScaling: true,
				scaleX: 0.3,
				scaleY: 0.3,
				left: randomLeft + 100,
				top: randomTop + 150,
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
			});

			imgObj.lockScalingX = true;
			imgObj.lockScalingY = true;
			imgObj.hasRotatingPoint = true;

			canvas.add(imgObj);
			canvas.setActiveObject(imgObj);
		};

		img.src = src;
	};

	const replaceImage = (activeObject) => {
		if (!activeObject) return;

		const isFlipped = activeObject.isFlipped;
		const newImageSrc = isFlipped
			? activeObject.frontImage
			: activeObject.backImage;

		activeObject._element.src = newImageSrc;
		activeObject.isFlipped = !isFlipped;
		activeObject._element.onload = () => canvasInstance.current.renderAll();
	};

	const bringForward = (activeObject) => {
		if (activeObject) {
			canvasInstance.current.bringObjectForward(activeObject, true);
			canvasInstance.current.renderAll();
		}
	};

	const sendBackward = (activeObject) => {
		if (activeObject) {
			canvasInstance.current.sendObjectBackwards(activeObject, true);
			canvasInstance.current.renderAll();
		}
	};

	return <canvas width="750" height="370" ref={canvasRef} />;
}

export default App;

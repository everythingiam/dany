import { useEffect } from 'react';

function useIntervalQuery(callback, delay) {
	useEffect(() => {
		callback();

		const id = setInterval(callback, delay);
		return () => clearInterval(id); 
	}, [callback, delay]);
}

export default useIntervalQuery;

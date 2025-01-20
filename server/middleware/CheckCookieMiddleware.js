module.exports = function checkCookieToken(req, res, next) {
	const token = req.cookies.session_token;

	if (!token) {
		return res.status(400).json({
			status: 'error',
			message: 'No session token provided',
		});
	}

	req.token = token; 
	next();
}

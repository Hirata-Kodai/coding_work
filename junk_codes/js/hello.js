'use strict';

let main = () => {
	console.log('Hello World!');
	return;
}

if (require.main === module) {
	main()
}

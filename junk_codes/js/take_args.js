'use strict';

let main = () => {
	console.log(process.argv);
}

if (require.main === module) {
	main()
}

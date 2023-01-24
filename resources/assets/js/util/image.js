/**
 *
 * @param {String} file the file to convert
 * @param {Number} maxWidth the max width of the file
 * @param {Number} maxHeight the max height of the file
 * @returns Image
 */
const canvasProcessor = require( "canvas_image_processing" );

export const createBase64ImageFromFile = function( file, maxWidth=100, maxHeight=100 ){
	return new Promise( function( resolve, reject ){
		const reader = new FileReader();

		reader.onload = function( e ) {
			let base64_image = e.target.result;

			var i = new Image();
			var dimensions;

			i.onload = function(){

				dimensions = {
					"width" : i.width,
					"height" : i.height
				}

				var ratio = 0;
				var width = dimensions.width;
				var height = dimensions.height;
				var newWidth = width;
				var newHeight = height;

				// Check if the current width is larger than the max
				if(width > maxWidth){
					ratio = maxWidth / width;   // get ratio for scaling image
					newHeight = height * ratio;    // Reset height to match scaled image
					newWidth = width * ratio;    // Reset width to match scaled image
				}

				// Check if current height is larger than max
				if(height > maxHeight){
					ratio = maxHeight / height; // get ratio for scaling image
					newWidth = width * ratio;    // Reset width to match scaled image
					newHeight = height * ratio;    // Reset height to match scaled image
				}

				canvasProcessor.resizeImage64( base64_image, newWidth, newHeight ).then(
					( resized_image ) => canvasProcessor.cropImage64( resized_image, 0, 0, newWidth, newHeight)
														.then( cropped_image => resolve( cropped_image ) )
														.catch( () => resolve( base64_image ) )
				);


			};

			// The assigment of this variable fires the onload for the image
			i.src = base64_image;

		};
		try{
			reader.readAsDataURL( file );
		} catch( err ){
			reject( err );
		}
	} );

}
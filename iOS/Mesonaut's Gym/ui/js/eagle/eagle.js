var touchstart = -1;
var lastthingtouched = -1;
var zoomed = -1;
var delay = 1000;

function EagleModel() {
	this.newdata = false;
}

EagleModel.prototype = new Modell(64);

EagleModel.prototype.setup = function() {
	
};

EagleModel.prototype.update = function(currentTimeMillis) {
	for ( var i = 0; i < numberOfThings; i++) {
	//	if (allThings[i] instanceof Widget)
			allThings[i].update();
	}
};

EagleModel.prototype.touch = function(x, y) {
};

EagleModel.prototype.touchStart = function(x, y) {
};

EagleModel.prototype.touchStop = function(x, y) {
};

EagleModel.prototype.zoomIn = function(x, y) {
};

EagleModel.prototype.zoomOut = function(x, y) {
};


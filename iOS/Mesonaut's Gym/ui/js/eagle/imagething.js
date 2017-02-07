ImageThing.prototype = new Thing(1);

function ImageThing(image, w, h) {
	if(image!= undefined && image!= null) {
		this.setTexName(image);
	}
	this.imageInit(w, h);
}

ImageThing.prototype.imageInit = function(w, h) {
	this.parts = new Array(1);
	this.texID = 0;
	this.texidset = false;
	this.texchanged = true;
	this.rectangle = new Rectangle();
	this.rectangle.init(w, h, 0, 0, 0, 0, 0);
	this.add(this.rectangle);	
	this.setupDone();
};

ImageThing.prototype.scale = function(x, y) {
	this.setDimension(this.parts[0].width * 2*x, this.parts[0].height * 2* y);
//	this.sx*= x;
//	this.sy*= y;
};

ImageThing.prototype.getTexID = function() {
	return this.texID;
};

ImageThing.prototype.setTexID = function(i) {
	this.texidset = true;
	this.texID = i;
	this.texchanged = false;
};

ImageThing.prototype.setTexName = function(n) {
	this.texchanged = true;
	this.texName = n;
};

ImageThing.prototype.getTexName = function() {
	return this.texName;
};

ImageThing.prototype.getType = function() {
	return IMAGE;
};

ImageThing.prototype.getWidth = function() {
	return this.parts[0].width * 2;
};

ImageThing.prototype.getHeight = function() {
	return this.parts[0].height * 2;
};

ImageThing.prototype.setDimension = function(w, h) {
	this.parts[0].setDimension(w, h);
	this.texchanged = true;
	this.invalidateData();
};

ImageThing.prototype.getHeight = function() {
	return this.parts[0].height * 2;
};

ImageThing.prototype.getRectangle = function() {
	return this.parts[0];
};

ImageThing.prototype.isTexIDSet = function() {
	return this.texidset;
};

ImageThing.prototype.isIn = function(ix, iy) {
	 ix-= w2;
     iy-= h2;
     
     if(ix> this.x+this.rx-this.getWidth()/2 && ix< this.x+this.rx+this.getWidth()/2 && iy> this.y+this.ry- this.getHeight()/2 && iy< this.y+this.ry+this.getHeight()/2)
             return true;
     return false;
//	return this.rectangle.isIn(ix, iy);
};



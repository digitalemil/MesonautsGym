Quadrangle.prototype = new Part();

function Quadrangle() {
}

Quadrangle.prototype.init = function(ix1, iy1, ix2, iy2, ix3, iy3, ix4, iy4, irx, iry, irz, ir, ic) {
	this.setRoot(irx, iry, irz, ir);
	this.width = w / 2;
	this.height = h / 2;
	this.sx = 1;
	this.sy = 1;
	this.setColor(ic);
	this.x1= ix1;
	this.x2= ix2;
	this.x3= ix3;
	this.x4= ix4;
	
	this.y1= iy1;
	this.y2= iy2;
	this.y3= iy3;
	this.y4= iy4;
	
	this.tx_width = 0;
	this.tx_height = 0;
	this.tx_sx = 1;
	this.tx_sy = 1;
};

Quadrangle.prototype.QuadrangleBeginTX = function() {
	this.partBeginTX();
	this.tx_sx = this.sx;
	this.tx_sy = this.sy;
	this.tx_x1= this.x1;
	this.tx_x2= this.x2;
	this.tx_x3= this.x3;
	this.tx_x4= this.x4;
	
	this.tx_y1= this.y1;
	this.tx_y2= this.y2;
	this.tx_y3= this.y3;
	this.tx_y4= this.y4;	
};

Quadrangle.prototype.commitTX = function() {
	this.QuadrangleCommitTX();
};

Quadrangle.prototype.beginTX = function() {
	this.QuadrangleBeginTX();
};

Quadrangle.prototype.rollbackTX = function() {
	this.QuadrangleRollbackTX();
};

Quadrangle.prototype.QuadrangleCommitTX = function() {
	this.partCommitTX();
};

Quadrangle.prototype.QuadrangleRollbackTX = function() {
	this.partRollbackTX();
	this.sx = this.tx_sx;
	this.sy = this.tx_sy;
	this.x1= this.tx_x1;
	this.x2= this.tx_x2;
	this.x3= this.tx_x3;
	this.x4= this.tx_x4;
	
	this.y1= this.tx_y1;
	this.y2= this.tx_y2;
	this.y3= this.tx_y3;
	this.y4= this.tx_y4;
};

Quadrangle.prototype.reset = function() {
	this.partreset();
};


Quadrangle.prototype.getNumberOfData = function() {
	return 4 + 2 * 5; // type, n, color, data 4*(x & y)
};

Quadrangle.prototype.getData = function(d, startD, xn, yn, zn, a11, a21, a12,
		a22) {
	if(this.parent.getType()== "THING")
	 console.log("Quadrangle getData: "+startD+ " "+this.width+" "+this.height);
	var n = startD;
	d[n++] = this.getType();
	d[n++] = 4;
	d[n++] = (this.a << 24) | (this.r << 16) | (this.g << 8) | this.b;
	d[n++] = 1;
	n += 2;
	var phi = calcPhi(this.rot + this.rrot);
	var sinbeta = mysin[phi];
	var cosbeta = mycos[phi];
	var dummy;
	var dummy2;
	var xmin = 1000000;
	var xmax = -1000000;
	var ymin = 1000000;
	var ymax = -1000000;

	
	dummy = this.x1 * cosbeta - this.y1 * sinbeta + this.rx + this.x;
	dummy2 = this.x1 * sinbeta + this.y1 * cosbeta + this.ry + this.y;
	d[n] = Math.round(dummy * a11 + dummy2 * a12 + xn);
	d[n + 1] = Math.round(dummy * a21 + dummy2 * a22 + yn);
	if(d[n]< xmin)
		xmin= d[n];
	if(d[n]> xmax)
		xmax= d[n];
	if(d[n+1]< ymin)
		ymin= d[n+1];
	if(d[n+1]> ymax)
		ymax= d[n+1];
	
	dummy = this.x2 * cosbeta - this.y2 * sinbeta + this.rx + this.x;
	dummy2 = this.x2 * sinbeta + this.y2 * cosbeta + this.ry + this.y;
	d[n + 2] = Math.round(dummy * a11 + dummy2 * a12 + xn);
	d[n + 3] = Math.round(dummy * a21 + dummy2 * a22 + yn);
	if(d[n+2]< xmin)
		xmin= d[n+2];
	if(d[n+2]> xmax)
		xmax= d[n+2];
	if(d[n+3]< ymin)
		ymin= d[n+3];
	if(d[n+3]> ymax)
		ymax= d[n+3];

	dummy = this.x3 * cosbeta - this.y3 * sinbeta + this.rx + this.x;
	dummy2 = this.x3 * sinbeta + this.y3 * cosbeta + this.ry + this.y;
	d[n + 4] = Math.round(dummy * a11 + dummy2 * a12 + xn);
	d[n + 5] = Math.round(dummy * a21 + dummy2 * a22 + yn);
	if(d[n+4]< xmin)
		xmin= d[n+4];
	if(d[n+4]> xmax)
		xmax= d[n+4];
	if(d[n+5]< ymin)
		ymin= d[n+5];
	if(d[n+5]> ymax)
		ymax= d[n+5];

	dummy = this.x4 * cosbeta - this.y4 * sinbeta + this.rx + this.x;
	dummy2 = this.x4 * sinbeta + this.y4 * cosbeta + this.ry + this.y;
	d[n + 6] = Math.round(dummy * a11 + dummy2 * a12 + xn);
	d[n + 7] = Math.round(dummy * a21 + dummy2 * a22 + yn);
	if(d[n+6]< xmin)
		xmin= d[n+6];
	if(d[n+6]> xmax)
		xmax= d[n+6];
	if(d[n+7]< ymin)
		ymin= d[n+7];
	if(d[n+7]> ymax)
		ymax= d[n+7];
	
	if (this.coordtap != null) {
		this.coordtap.save(0, 0, 0, xmin, xmax, ymin, ymax);
	}
//	console.log(d[n]+" "+d[n+1]+ " "+d[n+2]+" "+d[n+3]+" "+d[n+4]+" "+d[n+5]+" "+d[n+6]+" "+d[n+7]);

	return this.getNumberOfData();
};

Quadrangle.prototype.scale = function(isx, isy) {
	this.width *= isx;
	this.height *= isy;
};

Quadrangle.prototype.setDimension = function(w, h) {
	this.width = w / 2;
	this.height = h / 2;
};

Quadrangle.prototype.getType = function() {
	return QUADRANGLE;
};
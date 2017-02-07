function Screen() {
	this.id= 0;
	this.menu= 0;
	this.maxmenu= 0;
	this._start= 0;
	this.frames= -1;
	this.fps= 0;
	this.nextscreen= Screen.STAYONSCREEN;
}

Screen.MAXSCREEN= 256;
Screen.screens= new Array(this.MACSCREEN); 
Screen.activeScreen= -1;
Screen.screen= -1;
Screen.STAYONSCREEN= -1;

Screen.prototype.menuClick = function() {
		
};

Screen.prototype.menuUp= function() {
		var d= this.menu;
		if(this.menu> 0)
			this.menu--;
		if(d!= this.menu) {
			this.handleMenu(d, this.menu);
		}
};
	
Screen.prototype.menuBack= function() {
};
	
Screen.prototype.menuDown= function() {
		var d= menu;
		if(this.menu< this.maxmenu-1)
			this.menu++;
		if(d!= this.menu) {
			this.handleMenu(d, this.menu);
		}		
};
	
Screen.prototype.setMaxMenu= function(max) {
	this.maxmenu= max;
};
	
Screen.prototype.resetMenu= function() {
		this.maxmenu= this.menu= 0;
};
	
Screen.prototype.handleMenu= function(before, after) {
};

	
Screen.prototype.isFireTV= function() {
		return Globals.isFireTV();
};

/*
Screen.prototype.getNumberOfThings= function() {
		return this.numberOfThings;
};
*/

Screen.prototype.getFps= function() {
		return this.fps;
};
	
Screen.prototype.update= function(currentTimeMillis) {
		this.frames++;
		if (this._start == 0)
			this._start = PartAnimation.prototype.currentTimeMillies();

		var now = PartAnimation.prototype.currentTimeMillies();
		if (now - this._start > 1000) {
			fps = ((1000 * this.frames) / (now - this._start));
			this._start = 0;
			this.frames = 0;
		}
		return false;
};

Screen.getActiveScreen= function() {
		if(Screen.activeScreen< 0 || Screen.activeScreen>= Screen.MAXSCREEN)
			return null;
		return Screen.screens[Screen.activeScreen];
};

		
Screen.prototype.activate= function(id) {
		Screen.activeScreen= id;
//		console.log("Screen activate: "+Screen.activeScreen+ " "+this.id);		
		this._start = 0;
		this.frames = 0;
		this.nextscreen= Screen.STAYONSCREEN;	
};
	
Screen.prototype.deactivate= function() {
		for(i= 0; i< maxNumberOfThings; i++)
			allThings[i]= null;
};
	
Screen.prototype.moveToOtherScreen= function() {
	//console.log("Screen: "+this+" "+this.nextscreen);
		return this.nextscreen;
};
	
Screen.prototype.fillThingArray= function(things) {	
		return getNumberOfThings();
};
	
Screen.prototype.touch= function(x, y) {
};

Screen.prototype.touchStart= function(x, y) {
		return false;
};

Screen.prototype.touchStop= function(x, y) {
		return false;
};
	
Screen.prototype.getScreenID= function() {
		return this.id;
};
	
Screen.getScreen= function(id) {
		return Screen.screens[id];
};
	
Screen.registerScreen= function(screen) {
		Screen.screens[screen.getScreenID()]= screen;
};

Screen.prototype.getBackgroundColor= function() {
		return 0;
};

Screen.prototype.setNextScreen= function(s) {
		this.nextscreen= s;
};

var screen= new Screen();

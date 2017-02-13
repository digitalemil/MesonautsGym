function Modell(n) {
	this.init(n);
}

Modell.prototype.init= function(n) {
		allThings = new Array(n);
		maxNumberOfThings= n;
		this.start = 0;
		this.fps= 0;
		this.frames= 0;
};

Modell.prototype.moveToOtherScreen= function() {
    if(Screen.getActiveScreen()!= null)
        return Screen.getActiveScreen().moveToOtherScreen();
    else
        return Screen.STAYONSCREEN;
};

Modell.prototype.getBackgroundColor= function() {
	if (Screen.getActiveScreen() != null)
		return Screen.getActiveScreen().getBackgroundColor();
	return 0;
};

Modell.prototype.showScreen= function(id) {
    if (Screen.getActiveScreen() != null && Screen.getActiveScreen() != undefined)
            Screen.getActiveScreen().deactivate();
 //   console.log("id: "+id);
    Screen.getScreen(id).activate();
};

Modell.prototype.modellupdate= function(currentTimeMillies) {
		this.frames++;
		if (this.start == 0)
			this.start = PartAnimation.prototype.currentTimeMillies();
		var now = PartAnimation.prototype.currentTimeMillies();
		if (now - this.start > 1000) {
			this.fps = Math.floor(((1000 * this.frames) / (now - this.start)));
			this.start = 0;
			this.frames = 0;
		}
};


Modell.prototype.setNumberOfThings= function(n) {
	numberOfThings= n;
};

Modell.prototype.getFps= function() {
		return this.fps;
};

Modell.prototype.getNumberOfThings= function() {
		return numberOfThings;
};

Modell.prototype.isVisible= function(t) {
		return allThings[t].visible;
};

Modell.prototype.hasChanged= function(t) {
		return allThings[t].hasChanged();
};

Modell.prototype.getType= function(t) {
//	alert(allThings);
		return allThings[t].getType();
};

Modell.prototype.getTexID= function(t) {
		return allThings[t].getTexID();
};

Modell.prototype.getData= function(t) {
		return allThings[t].getThingData();
};

Modell.prototype.getTextAndFont= function(t) {
	return allThings[t].getThingTextAndFont();
};

Modell.prototype.getImageWidth= function(t) {
	return allThings[t].getWidth();
};

Modell.prototype.getImageHeight= function(t) {
	return allThings[t].getHeight();
};

Modell.prototype.getTexName= function(t) {
	return allThings[t].getTexName();
};

Modell.prototype.getNumberOfData= function(t) {
		return allThings[t].getNumberOfData();
};

Modell.prototype.texNameChanged= function(t) {
		return allThings[t].texchanged;
};

Modell.prototype.isTexIDSet= function(t) {
		return allThings[t].texidset;
};

Modell.prototype.setTexID= function(t, i) {
		allThings[t].setTexID(i);
};

Modell.prototype.getRotation= function(t) {
	return allThings[t].rot;
};

/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

//Extend Sortables class to enable sort element in horizontal direction
HSortables = Sortables.extend ({
	options: {
		horizontal: true,
		onDragStart: function(element, ghost){
			ghost.setStyle('opacity', this.options.opacity);
			element.setStyle('opacity', this.options.opacity);
			ghost.addClass (this.options.ghost_class);
		}
	},
	
	initialize: function(el, options){
		this.setOptions(options);
		this.parent(el);
	},
	
	
	moveGhost: function(event){
		var value = event.page.x - this.offset;
		value = value.limit(this.coordinates.left, this.coordinates.right - this.ghost.offsetWidth);
		this.ghost.setStyle('left', value);
		event.stop();
	},
	
	move: function(event){
		if (!this.options.horizontal) {
			this.parent(event);
			return;
		}
		var now = event.page.x;
		this.previous = this.previous || now;
		var up = ((this.previous - now) > 0);
		var prev = this.active.getPrevious();
		var next = this.active.getNext();
		if (prev && up && now < prev.getCoordinates().right) this.active.injectBefore(prev);
		if (next && !up && now > next.getCoordinates().left) this.active.injectAfter(next);
		this.previous = now;
	}, 
	
	start: function (event, el) {
		if (this.list.disabled) return;
		this.parent (event, el);
	}
});

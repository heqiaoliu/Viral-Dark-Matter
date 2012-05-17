var JATypo = new Class ({
	initialize: function(options) {
		this.options = $extend({
			offsets: {x:10, y: 10}
		}, options || {});
		this.wrapper = $('jatypo-wrap');		
		if (!this.wrapper) return;
		this.typos = this.wrapper.getElements ('.typo');
		this.typos.addEvents ({	
			'mouseenter': function (){
				this.getElement('.sample').setStyle('display','block');
				
				this.addClass ('typo-over');
				//detect popup position
				var wrapper = $('jatypo-wrap');
				var sample = this.getElement ('.sample');
				var pos_s = findPos (sample);
				var pos_w = findPos (wrapper);
				var scroll_w = {x: wrapper.scrollLeft, y: wrapper.scrollTop};
				
				var x0 = pos_w.x + scroll_w.x;
				var y0 = pos_w.y + scroll_w.y;
				var w0 = wrapper.offsetWidth;
				var h0 = wrapper.offsetHeight;
				var x1 = pos_s.x;
				var y1 = pos_s.y;
				var w1 = sample.offsetWidth;
				var h1 = sample.offsetHeight;
				
				//Detect class need to add to ajdust the position of sample popup
				if (y1<y0) {this.addClass ('typo-top').removeClass ('typo-bottom')}
				if (y1+h1>y0+h0) {this.addClass ('typo-bottom').removeClass ('typo-top')}
				if (x1<x0) {this.addClass ('typo-left').removeClass ('typo-right')}
				if (x1+w1>x0+w0) {this.addClass ('typo-right').removeClass ('typo-left')}
				
				
				
			},
			'mouseleave': function (){this.getElement('.sample').setStyle('display','none');},
			'click': function (){
				var sample = this.getElement ('.sample');
				var html = sample.innerHTML;
				window.parent.insertTypoHTML(html.trim());
				window.parent.SqueezeBox.close();		
			}
		});		
	}
});

function findPos (obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		do {
			curleft += obj.offsetLeft;
			curtop += obj.offsetTop;
		} while (obj = obj.offsetParent);
	}

	return {x:curleft,y:curtop};
}
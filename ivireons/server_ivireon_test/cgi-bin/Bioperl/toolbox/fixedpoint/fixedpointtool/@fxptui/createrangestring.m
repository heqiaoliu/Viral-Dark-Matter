function rangestr = createrangestring(rmin, rmax)
%CREATERANGESTRING   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:53 $

	strrmin = sprintf('%0.3g', rmin);
  strrmax = sprintf('%0.3g', rmax);
	rangestr = '';
	if(~isempty(strrmin) && ~isempty(strrmax))
		rangestr = ['[' strrmin '  ' strrmax ']'];
	end

% [EOF]

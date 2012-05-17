function view(h)
%VIEW   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:01:38 $

if(~isa(h, 'DAStudio.Object') || isempty(h.daobject))
	return;
end
h.daobject.view;

% [EOF]

function me = getexplorer(this)
%GETEXPLORER   Get the explorer.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:57:59 $

daRoot = DAStudio.Root;
me = daRoot.find('-isa', 'fxptui.explorer');
if(~isa(me, 'fxptui.explorer'));
	me = [];
end

% [EOF]

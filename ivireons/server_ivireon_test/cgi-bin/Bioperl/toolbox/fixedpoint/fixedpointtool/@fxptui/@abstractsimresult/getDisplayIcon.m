function val = getDisplayIcon(this)
%GETDISPLAYICON

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/14 19:35:11 $

val= '';
% Using the overloaded UDD find and not the built in method.
if(isempty(find(this.daobject, '-depth', 0 , '-isa', 'DAStudio.Object')));return;end; %#ok<GTARG>

if(isempty(this.Signal))
	val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['BlockIcon' this.Alert '.png']);
else
	val = fullfile('toolbox','fixedpoint','fixedpointtool','resources',['BlockLoggedIcon' this.Alert '.png']);
end

% [EOF]
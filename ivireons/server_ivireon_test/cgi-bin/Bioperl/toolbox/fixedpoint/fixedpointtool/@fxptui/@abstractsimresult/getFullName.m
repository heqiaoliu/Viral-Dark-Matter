function name = getFullName(this)
%GETFULLNAME   Get the fullName.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:57 $

name = '';
if(isa(this.daobject, 'DAStudio.Object'))
	name = fxptds.getpath(this.daobject.getFullName);
end

% [EOF]

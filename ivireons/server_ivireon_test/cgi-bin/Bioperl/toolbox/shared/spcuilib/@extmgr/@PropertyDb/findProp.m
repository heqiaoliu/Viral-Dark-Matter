function hProperty = findProp(this,theName)
%FINDPROP Find extension property in database.
%  FINDPROP(H,'Name') returns specified property in database.
%  If not found, empty is returned.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:46:36 $

% hProperty = iterator.findImmediateChild(this, ...
%     @(hProperty)strcmpi(hProperty.Name,theName));

% This is faster, still case-independent since UDD offers that
% service via find implicitly:
hProperty = findChild(this, 'Name', theName);

% [EOF]

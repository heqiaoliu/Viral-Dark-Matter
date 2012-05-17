function childClass = getChildClass(this) %#ok
%GETCHILDCLASS Returns the class of the valid children.
%   GETCHILDCLASS(H) Returns 'handle' at the abstract level as the abstract
%   Database forces no restrictions on its children.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:49 $

% This method should be "protected".

childClass = 'handle';

% [EOF]

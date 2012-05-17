function s = saveobj(this)
%SAVEOBJ  Save this object.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/08/03 21:37:25 $

% Get the name of the concrete class that is being saved.
s.class = class(this);

% Save all the children.
s.Children = allChild(this);

% [EOF]

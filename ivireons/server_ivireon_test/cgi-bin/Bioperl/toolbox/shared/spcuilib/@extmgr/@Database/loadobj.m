function this = loadobj(s)
%LOADOBJ  Load this object.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/09/09 21:28:59 $

% Create a new object.
if isstruct(s)
    this = feval(s.class);
    
    % Add the children.
    for indx = 1:length(s.Children)
        add(this, s.Children(indx));
    end
else
    this = s;
end

% [EOF]

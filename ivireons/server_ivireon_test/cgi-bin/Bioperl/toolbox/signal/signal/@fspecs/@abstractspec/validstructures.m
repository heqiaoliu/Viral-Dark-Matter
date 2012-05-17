function vs = validstructures(this, method)
%VALIDSTRUCTURES   Return the valid structures.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:57:38 $

if nargin > 1

    % If we are given a method use it.
    d  = feval(getdesignobj(this, method));
    vs = getvalidstructs(d);
else
    
    % Get the valid structures for each of the specifications.
    d_info = getdesignobj(this);
    fn = fieldnames(d_info);
    for indx = 1:length(fn)
        d = feval(d_info.(fn{indx}));
        vs.(fn{indx}) = getvalidstructs(d);
    end
end

% [EOF]

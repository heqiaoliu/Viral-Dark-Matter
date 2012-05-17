function validaterefcoeffs(~, prop, val)
%VALIDATEREFCOEFFS   

%   Author(s): V. Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:10:09 $

if ~(strcmpi(class(val), 'double') || strcmpi(class(val), 'single') ...
        || strcmpi(class(val), 'embedded.fi') ...
        || strncmpi(class(val), 'int', 3) || strncmpi(class(val), 'uint', 4)),
    error(generatemsgid('invalidDataType'),...
        '%s must be of class fi, double, int* or uint*.',prop);
end

if issparse(val),
    error(generatemsgid('invalidDataType'),...
        '%s cannot be a sparse matrix.',prop);
end

if strcmpi(prop, 'sosMatrix'),
    if any(val(:,4)~=1),
        % a0 must be exactly equal to 1 or an error will occur.
        error(generatemsgid('invalidsosMatrix'), ...
            'The 4th column of the sosMatrix must contain only 1.');
    end
end


% [EOF]

function bool = isminord(d)
%ISMINORD Returns true if the object is minimum order.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 18:12:55 $

try
    bool = strcmpi(d.ordermode, 'minimum');
catch
    
    % The ordermode property is private or not there when the object is not
    % minimum order, so the above get will fail.
    bool = false;
end    

% [EOF]

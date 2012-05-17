function type = gettype(hC)
%GETTYPE Returns the type of the Complex Number

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:21:10 $

if length(hC) > 1,
    type = 's';
else
    type = '';
end

if isempty(find(hC, '-isa', 'sigaxes.pole')),
    type = ['Zero' type];
elseif isempty(find(hC, '-isa', 'sigaxes.zero')),
    type = ['Pole' type];
else
    type = 'Poles and Zeros';
end


% [EOF]

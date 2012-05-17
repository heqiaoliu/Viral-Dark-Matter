function setvalue(hC, n)
%SETVALUE Set the value of the PZ

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:21:12 $

% Loop over each object and set its imaginary and real parts
for indx = 1:min(length(hC), length(n))
    set(hC(indx), 'Real', real(n(indx)));
    set(hC(indx), 'Imaginary', imag(n(indx)));
end

send(hC(1), 'NewValue', handle.EventData(hC(1), 'NewValue'));

% [EOF]

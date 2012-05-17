function h = splitconjugate(hC)
%SPLITCONJUGATE Separate the PZ from its conjugate
%   SPLOTCONJUGATE(hC) Separate the PZ object hC from its conjugate.
%   Return the handle to the conjugate.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:21:13 $

h = {};

for indx = 1:length(hC)
    
    % Create conjugate objects for each of the objects that we are
    % splitting.
    if strcmpi(hC(indx).Conjugate, 'On'),
        h{indx} = feval(class(hC(indx)), conj(double(hC(indx))));
    end
end
set(hC, 'Conjugate', 'Off');

h = [h{:}];

% [EOF]

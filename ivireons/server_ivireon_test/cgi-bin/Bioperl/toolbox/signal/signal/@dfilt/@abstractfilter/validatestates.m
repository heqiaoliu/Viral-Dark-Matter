function validatestates(h)
%VALIDATESTATES   

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/10/18 21:00:21 $

w = warning('off');
[wid, wstr] = lastwarn;

try
    % Validate or quantize states
    h.HiddenStates = validatestates(h.filterquantizer,h.HiddenStates);    
catch
    % NO OP
end

warning(w);
lastwarn(wid, wstr);

% [EOF]

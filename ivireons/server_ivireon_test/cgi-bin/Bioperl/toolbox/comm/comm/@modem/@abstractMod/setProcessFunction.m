function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set ProcessFunction property of modulator object H.

% @modem/@abstractMod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:44 $

if strcmpi(h.InputType, 'bit')
    h.ProcessFunction = @modulate_Bit;
else
    % InputType = 'Integer'
    h.ProcessFunction = @modulate_Int;
end

%--------------------------------------------------------------------
% [EOF]
    
    
        
        
        
        
        

        
function setProcessFunction(h, M) %#ok
%SETPROCESSFUNCTION Set ProcessFunction property of modulator object H.

% @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:11 $

if strcmpi(h.Precoding, 'off')
    h.ProcessFunction = @modulate_Conventional;
else
    h.ProcessFunction = @modulate_Precoded;
end

%--------------------------------------------------------------------
% [EOF]
    
    
        
        
        
        
        

        
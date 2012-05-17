function saveparameters(hFVT)
%SAVEPARAMETERS Save the parameters for use by another FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:27:49 $ 

if get(hFVT,'ParametersDirty'),
    
    hPrms = get(hFVT, 'Parameters');
    
    % We need to loop over these because of the dynamic property
    for i = 1:length(hPrms),
        data(i) = get(hPrms(i));
    end
    
    setpref('SignalProcessingToolbox', 'FvtoolParameters', data);
    set(hFVT, 'ParametersDirty', 0);
end

% [EOF]

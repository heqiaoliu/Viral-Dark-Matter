function bfitSetListenerEnabled(L, state)
%BFITSETLISTENERENABLED   Set the enabled state for a listener
%
%   BFITSETLISTENERENABLED(L, STATE) sets the enabled state of the listener L.
%   STATE is a logical scalar.  This function will work correctly with both
%   old and new style listeners.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2009/01/29 17:16:21 $ 

% HG1/HG2 Safe way to set the Enabled property of a listener
if feature('HGUsingMATLABClasses')
    L.Enabled = state;
else
    if state
        L.Enabled = 'on';
    else
        L.Enabled = 'off';
    end
end

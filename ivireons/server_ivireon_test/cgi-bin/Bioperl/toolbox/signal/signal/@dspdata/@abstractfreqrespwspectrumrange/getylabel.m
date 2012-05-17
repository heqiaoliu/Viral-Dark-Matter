function ylbl = getylabel(this)
%GETYLABEL Get the ylabel.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:02 $

if this.plotindb             
    ylbl = 'Magnitude (dB)';
else
    ylbl = 'Magnitude';
end


% [EOF]

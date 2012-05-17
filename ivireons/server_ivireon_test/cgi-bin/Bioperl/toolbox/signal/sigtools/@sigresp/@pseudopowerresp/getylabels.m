function ylabels = getylabels(this)
%GETYLABELS  Method to get the list of strings to be used for the ylabels.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2008/03/31 17:11:50 $

if isempty(this.Spectrum)
    dataunits = '';
else
    dataunits = sprintf(' (%s)', this.Spectrum.MetaData.DataUnits);
end

lblstr = 'Power';
ylabels = {...
        sprintf('%s%s',lblstr,dataunits), ...
        [lblstr,' (dB)']};

% [EOF]
function str = getylabel(this)
%GETYLABEL Returns the string to be used on the Y Label

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/13 00:20:44 $

str = sprintf('%s (%s)', xlate(get(this, 'PhaseDisplay')), ...
    xlate(lower(get(this, 'PhaseUnits'))));


% [EOF]

function fr = dm_whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/08/26 19:40:46 $

% Get frames from the filter type
fr = whichframes(get(h,'responseTypeSpecs'));



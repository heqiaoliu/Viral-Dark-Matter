function hideFixedPointProperties
%hideFixedPointProperties Turn off the display of fixed-point properties.
%   hideFixedPointProperties turns off the display of fixed-point
%   properties. Display of fixed-point properties can also be turned off
%   using the MATLAB preferences dialog box. To do this, select File >
%   Preferences on the MATLAB desktop, then select System Objects, and
%   deselect Show fixed-point properties.
%
%   This function calls the setpref function to set the
%   DisplayFixedPointProperties preference in the SystemObjects preference
%   group to false.
%
%   See also matlab.system.showFixedPointProperties, setpref.

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:48:35 $

setpref('SystemObjects', 'DisplayFixedPointProperties', false);

% [EOF]

function showFixedPointProperties
%showFixedPointProperties Turn on the display of fixed-point properties.
%   showFixedPointProperties turns on the display of fixed-point
%   properties. Display of fixed-point properties can also be turned on
%   using the MATLAB preferences dialog box. To do this, select File >
%   Preferences on the MATLAB desktop, then select System Objects, and
%   select Show fixed-point properties.
%   
%   This function calls the setpref function to set the
%   DisplayFixedPointProperties preference in the SystemObjects preference
%   group to true.
%
%   See also matlab.system.hideFixedPointProperties, setpref.

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:48:36 $

setpref('SystemObjects', 'DisplayFixedPointProperties', true);

% [EOF]

function fsh = construct_ff(h)
%CONSTRUCT_FF  Construct a freq frame
%   UNITS   -   The default units for the units popup
%   FS      -   The sampling frequency

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:30:30 $

% Create the FSSpecifier object and store it's handle
% We use FSspecifier's default constructor for now.
fsh = siggui.specsfsspecifier;
addcomponent(h, fsh);

% [EOF]

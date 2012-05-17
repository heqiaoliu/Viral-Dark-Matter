function this = winspecs
%WINSPECS Constructor for the winspecs object.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/12/26 22:22:39 $

% Instantiate the object
this = siggui.winspecs;

% Set up the default
set(this, ...
    'Window', sigwin.hamming, ...
    'SamplingFlag', 'symmetric', ...
    'isModified' , 0, ...
    'Version', 1);

% [EOF]

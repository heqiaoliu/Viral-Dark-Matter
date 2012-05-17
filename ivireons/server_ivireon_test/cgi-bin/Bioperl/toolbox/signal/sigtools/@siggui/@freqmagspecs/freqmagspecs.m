function h = freqmagspecs(defaultUnits, defaultFs, defaultLbls, defaultValues, defaultName)
%FREQMAGSPECS is the constructor for the freqspecs object
%   FREQMAGSPECS(UNITS, FS, Lbls, Values, Name)
%   UNITS   -   The default units for the units popup
%   FS      -   The sampling frequency
%   Lbls    -   The labels of the edit boxes
%   Values  -   The values of the frequency specifications
%   Name    -   The frame name (optional)

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.4 $  $Date: 2007/12/14 15:18:43 $

error(nargchk(0,5,nargin,'struct'));

% Built in constructor call
h = siggui.freqmagspecs;

% Call the super constructor for freq frames to add an fsspecifier
fsh = construct_ff(h);

% Create a labelsandvalues object 
construct_mf(h, 'Maximum', 5);

settag(h);

% [EOF]

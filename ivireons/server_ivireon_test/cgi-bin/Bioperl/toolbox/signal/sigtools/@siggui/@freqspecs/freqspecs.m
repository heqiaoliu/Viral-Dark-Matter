function h = freqspecs
%FREQSPECS is the constructor for the freqspecs object
%   FREQSPECS(UNITS, FS, Lbls, Values, Name)
%   UNITS   -   The default units for the units popup
%   FS      -   The sampling frequency
%   Lbls    -   The labels of the edit boxes
%   Values  -   The values of the frequency specifications
%   Name    -   The frame name (optional)

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2007/12/14 15:18:44 $

error(nargchk(0,5,nargin,'struct'));

% Built in constructor call
h = siggui.freqspecs;

% Call the super constructor for freq frames to add an fsspecifier
construct_ff(h);

% Create a labelsandvalues object 
construct_mf(h);

settag(h);

% [EOF]

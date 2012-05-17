function dmfs_filterType_listener(h,varargin)
%FILTERTYPE_LISTENER Callback for listener to the filter type property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:26:59 $

% Call super's method
super_filterType_listener(h,varargin{:});

% Scale new frequencies according to current Fs and freqUnits
scaleFreqs(h);



    
    
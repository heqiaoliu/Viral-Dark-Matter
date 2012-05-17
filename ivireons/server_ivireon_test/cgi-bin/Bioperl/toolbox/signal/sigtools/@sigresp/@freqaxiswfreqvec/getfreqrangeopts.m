function rangeopts = getfreqrangeopts(varargin)
%GETFREQRANGEOPTS   Return the frequency range options.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:15 $

rangeopts = freqaxiswnfft_getfreqrangeopts(varargin{:});

% Append extra option specific to this class.
rangeopts{end+1} = 'Specify freq. vector';

% [EOF]

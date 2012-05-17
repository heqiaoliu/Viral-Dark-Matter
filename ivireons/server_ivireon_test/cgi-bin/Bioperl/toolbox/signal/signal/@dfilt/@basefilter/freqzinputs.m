function inputs = freqzinputs(Hd, varargin)
%FREQZINPUTS

%   Author: V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/07/29 21:41:46 $

[n, uc, fs, b] = freqzparse(varargin{:});
if b, inputs = {n, uc, fs};
else, inputs = {n, uc}; end

% [EOF]

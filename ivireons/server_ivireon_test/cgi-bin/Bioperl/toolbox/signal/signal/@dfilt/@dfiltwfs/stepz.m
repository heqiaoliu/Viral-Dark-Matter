function [y, t] = stepz(Hd, varargin)
%IMPZ Returns the impulse response

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/12/05 02:24:11 $

[y, t] = timeresp(Hd, @lclstepz, varargin{:});


% -------------------------------------------
function [y, t] = lclstepz(Hd, N, Fs)
    
if isempty(Fs), Fs = 1; end
[y, t] = stepz(Hd, N, Fs);

% [EOF]

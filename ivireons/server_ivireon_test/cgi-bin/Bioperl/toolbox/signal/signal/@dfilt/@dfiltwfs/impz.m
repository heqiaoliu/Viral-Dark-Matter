function [y, t] = impz(Hd, varargin)
%IMPZ Returns the impulse response

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2009/12/05 02:24:08 $

[y, t] = timeresp(Hd, @lclimpz, varargin{:});

% -----------------------------------------------------------
function [y, t] = lclimpz(G, N, Fs)

if isempty(Fs), Fs = 1; end
[y, t] = impz(G, N, Fs);

% [EOF]

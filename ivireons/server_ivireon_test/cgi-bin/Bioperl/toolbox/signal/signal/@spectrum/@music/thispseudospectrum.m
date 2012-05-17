function [Sxx,W] = thispseudospectrum(this,x,opts,P)
%THISPSEUDOSPECTRUM   Calculate the pseudospectrum via MUSIC.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2007/12/14 15:14:41 $

error(nargchk(2,4,nargin,'struct'));

if strcmpi(this.InputType,'CorrelationMatrix'),
    [Sxx W] = pmusic(x,P,'corr',opts{:});      
else
    [Sxx W] = pmusic(x,P,opts{:});  
end

% [EOF]

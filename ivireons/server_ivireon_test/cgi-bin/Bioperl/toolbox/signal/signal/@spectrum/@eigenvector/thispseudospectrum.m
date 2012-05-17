function [Sxx,W] = thispseudospectrum(this,x,opts,P)
%THISPSEUDOSPECTRUM   Calculate the pseudospectrum via Eigenvector analysis.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $Date: 2007/12/14 15:14:30 $

error(nargchk(2,4,nargin,'struct'));

if strcmpi(this.InputType,'CorrelationMatrix'),
    [Sxx W] = peig(x,P,'corr',opts{:});  
else
    [Sxx W] = peig(x,P,opts{:});  
end

% [EOF]

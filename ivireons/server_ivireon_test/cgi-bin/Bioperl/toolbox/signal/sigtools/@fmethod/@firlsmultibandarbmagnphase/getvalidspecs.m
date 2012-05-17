function [N,F,E,A,P,nfpts] = getvalidspecs(this,hspecs)
%GETVALIDSPECS   Get the validspecs.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:49 $

% Validate specifications
[N,F,E,H,nfpts] = validatespecs(hspecs);
A = abs(H);
P = angle(H);


% [EOF]

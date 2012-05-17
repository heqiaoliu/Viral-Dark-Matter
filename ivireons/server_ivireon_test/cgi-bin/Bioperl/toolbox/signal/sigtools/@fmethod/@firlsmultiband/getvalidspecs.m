function [N,F,E,A,P,nfpts] = getvalidspecs(this,hspecs)
%GETVALIDSPECS   Get the validspecs.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:43 $

% Validate specifications
[N,F,E,A,nfpts] = validatespecs(hspecs);
P = -N/2*pi*F;


% [EOF]

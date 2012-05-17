function p = thispropstosync(this, p)
%THISPROPSTOSYNC   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:35:51 $

% Remove FilterOrder because it must be even for certain specs and odd for
% others.
p(strmatch('FilterOrder',p)) = [];

% [EOF]

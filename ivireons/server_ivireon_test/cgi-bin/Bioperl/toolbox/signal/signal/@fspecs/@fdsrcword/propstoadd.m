function p = propstoadd(this)
%PROPSTOADD   

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:34 $

p = fieldnames(this);

% Remove the ResponseType
p(1) = [];

% Remove privInterpolationFactor and privDecimationFactor
p(end-1:end) = [];


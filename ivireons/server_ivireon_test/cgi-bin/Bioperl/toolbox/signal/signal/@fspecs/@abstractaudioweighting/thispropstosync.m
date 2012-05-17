function p = thispropstosync(this, p) %#ok<INUSL>
%THISPROPSTOSYNC   

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:50 $

% Remove properties in p. If specstring is toggled from 'WT' to 'WT,Class' then
% synchronizing the weighting type to the previous type will cause an error. So
% we must avoid this by deleting weightingtype from the structure.
idx = strcmpi('weightingtype',p);
p(idx) = [];

% [EOF]

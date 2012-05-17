function [p, v] = thisinfo(h)
%THISINFO Information for this class.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:16:42 $

[pvl, vvl] = varlen_thisinfo(h);
p = {pvl{:}, 'Sampling Flag'};
v = {vvl{:},get(h, 'SamplingFlag')};


% [EOF]
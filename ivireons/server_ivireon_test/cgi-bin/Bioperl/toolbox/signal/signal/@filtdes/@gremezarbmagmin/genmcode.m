function [params, values, descs, iargs] = genmcode(h, d)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:51:17 $

params = {'F', 'A', 'R'};
values = {getmcode(d, 'FrequencyVector'), getmcode(d, 'MagnitudeVector'), ...
        getmcode(d, 'RippleVector')};
descs = {'', '', ''};

iargs = sprintf('F%s, A, R', getfsstr(d));

% [EOF]

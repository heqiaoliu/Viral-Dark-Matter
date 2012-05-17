function [params, values, descs, iargs] = genmcode(h, d)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:51:23 $

[params, values, descs] = abstract_genmcode(h,d);

iargs = sprintf('F%s, A, W, ''hilbert''', getfsstr(d));

% [EOF]

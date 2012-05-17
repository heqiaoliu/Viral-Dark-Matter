function [p, v] = thisinfo(h)
%THISINFO Information for this class.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:35:48 $

p = {'MATLAB Expression'};
v = {get(h, 'MATLAB_expression')};

% [EOF]
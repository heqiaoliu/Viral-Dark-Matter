function [p, v] = varlen_thisinfo(h)
%VARLEN_THISINFO Information for variablelength class.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:27:24 $

p = {'Length'};
v = {sprintf('%g', get(h, 'length'))};

% [EOF]
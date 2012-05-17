function c = dfiltvariable(Hd)
%DFILTVARIABLE DFILT Variable string.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:07:58 $

c = cell(1,length(Hd.Stage));
for k=1:length(Hd.Stage)
  c{k} = dfiltvariable(Hd.Stage(k));
end

% [EOF]

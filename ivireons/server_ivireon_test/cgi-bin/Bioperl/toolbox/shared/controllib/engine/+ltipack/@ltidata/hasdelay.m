function boo = hasdelay(D)
% Returns TRUE if model has delays.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:17 $
Delay = D.Delay;
boo = any(Delay.Input) || any(Delay.Output) || any(Delay.IO(:));

function boo = isstatic(D)
% Returns TRUE if model is a pure gain.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:22 $
boo = isempty(D.a) && ~hasdelay(D);
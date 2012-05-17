function D = iorep(D,s)
% Replicates model along I/O dimensions.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:13 $
D.z = repmat(D.z,s);
D.p = repmat(D.p,s);
D.k = repmat(D.k,s);
D.Delay.Input = repmat(D.Delay.Input,[s(2) 1]);
D.Delay.Output = repmat(D.Delay.Output,[s(1) 1]);
D.Delay.IO = repmat(D.Delay.IO,s);

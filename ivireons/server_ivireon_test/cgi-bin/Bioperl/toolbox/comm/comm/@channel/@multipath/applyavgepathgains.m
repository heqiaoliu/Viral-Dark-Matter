function z = applyavgepathgains( chan, z )

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/03/26 01:07:12 $

APG = chan.AvgPathGainVector;

% Apply path gain factors.
z = repmat(APG, [1 size(z, 2)]) .* z;

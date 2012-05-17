function sys = hdsReplicateArray(sys,Pattern)
%HDSREPLICATE  Replicates data point array along grid dimensions.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:15:14 $
sys = repsys(sys,Pattern);
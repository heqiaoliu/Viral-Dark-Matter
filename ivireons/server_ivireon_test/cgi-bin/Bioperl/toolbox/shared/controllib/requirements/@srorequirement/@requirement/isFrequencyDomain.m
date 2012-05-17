function bFreq = isFrequencyDomain(this) 
% ISFREQUENCYDOMAIN  method to return boolean flag indicating whether a
% requirement is a frequency domain requirement
%
 
% Author(s): A. Stothert 04-Aug-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:21 $

nReq = numel(this);
bFreq = false(nReq,1);
for ct = 1:nReq
   bFreq(ct) = this(ct).isFrequencyDomain;
end

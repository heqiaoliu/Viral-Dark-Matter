function boo = hasDelay(this)
% Returns TRUE if the TunedLoop model has delays.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:22:05 $
if isempty(this.ContainsDelay)
    this.ContainsDelay = hasdelay(this.TunedLFT.IC);
end
boo = this.ContainsDelay;
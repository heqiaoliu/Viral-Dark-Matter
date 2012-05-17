function boo = hasFRD(this)
% Returns TRUE if the TunedLoop model has delays.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/26 17:22:06 $

if isempty(this.ContainsFRD)
    this.ContainsFRD = isa(this.TunedLFT.IC,'ltipack.frddata');
end
boo = this.ContainsFRD;
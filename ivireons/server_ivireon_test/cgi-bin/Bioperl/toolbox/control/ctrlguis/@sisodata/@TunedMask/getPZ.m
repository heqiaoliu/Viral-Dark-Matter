function [p,z] = getPZ(this)
% GETPZ Returns the poles and zeros of the TunedMask

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:09 $

% If zpkdata is empty update it
if isempty(this.ZPKData)
    this.updateZPK;
end

p = [this.ZPKData.p{:}];
z = [this.ZPKData.z{:}];
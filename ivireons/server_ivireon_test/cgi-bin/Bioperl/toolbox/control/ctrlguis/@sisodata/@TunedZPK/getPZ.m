function [Zeros,Poles] = getPZ(this,flag)
%GETPZ  Returns vectors of poles and zeros.
% 
%  getpz(this) gets poles and zeros of both pzgroups and fixed dynamics
%  getpz(this,'Tuned') gets poles and zeros of only the pzgroups

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:20 $


if isempty(this.PZGroup)
    Zeros = zeros(0,1);
    Poles = zeros(0,1);
else
    Zeros = get(this.PZGroup,{'Zero'});
    Zeros = cat(1,Zeros{:});
    Poles = get(this.PZGroup,{'Pole'});    
    Poles = cat(1,Poles{:});
end

if ~isempty(this.FixedDynamics) && (nargin == 1)
    Zeros = [Zeros;this.FixedDynamics.z{:}];
    Poles = [Poles;this.FixedDynamics.p{:}];
end
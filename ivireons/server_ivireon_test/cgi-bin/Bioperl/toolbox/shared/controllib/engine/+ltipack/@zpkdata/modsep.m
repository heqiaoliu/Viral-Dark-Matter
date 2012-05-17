function [D,D0] = modsep(D,varargin)
% Modal decomposition.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:48:14 $

% To avoid introducing internal delays in SS realization, cache
% delays and zero them out before conversion to SS
Delay = D.Delay;
[ny,nu] = iosize(D);
D.Delay = ltipack.utDelayStruct(ny,nu,false);
% Compute decomposition in state space
[Dss,D0ss] = modsep(ss(D),varargin{:});
% Convert back to ZPK and restore original delays
D = ltipack.zpkdata.array(size(Dss));
for ct=1:numel(D)
   D(ct) = zpk(Dss(ct));   D(ct).Delay = Delay;
end
D0 = zpk(D0ss); D0.Delay = Delay;

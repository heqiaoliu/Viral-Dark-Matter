function D = upsample(D,L)
%Upsample a discrete SS model by a factor of L.

%   Author: Murad Abu-Khalaf, April 30, 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:31:52 $
nx = size(D.a,1);
nxL = nx*(L-1);

% Expand the states according to:
%
% [ I  0 ]  [zk+1]    [ 0  I ] [ zk ]      [ 0 ]
% |      |  |    | =  |      | |    |   +  |   | uk
% [ 0  E ]  [xk+1]    [ A  0 ] [ xk ]      [ B ]
%
%                y =  [ C   0 ][ zk ]   +   D uk
%                              [ xk ]
D.a = [zeros(nxL,nx)   eye(nxL); D.a    zeros(nx,nxL)];
D.b = [zeros(nxL,size(D.b,2));  D.b];
D.c = [D.c  zeros(size(D.c,1),nxL)];
if ~isempty(D.e)
   D.e =  blkdiag(eye(nxL),D.e);
end
if ~isempty(D.StateName)
   D.StateName = [repmat({''},nxL,1); D.StateName];
end
if ~isempty(D.StateUnit)
   D.StateUnit = [repmat({''},nxL,1); D.StateUnit];
end
   
% Delays
D.Delay.Input = D.Delay.Input*L;
D.Delay.Output = D.Delay.Output*L;
D.Delay.Internal = D.Delay.Internal*L;
% Scaling
D.Scaled = false;

% Update the new sampling time.
D.Ts = D.Ts/L;


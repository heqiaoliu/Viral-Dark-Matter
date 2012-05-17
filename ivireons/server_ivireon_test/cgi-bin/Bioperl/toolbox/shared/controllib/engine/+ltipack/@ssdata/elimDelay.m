function [D,icmap] = elimDelay(D,id,od,fd,icmap)
% Maps specified portion of the delays to 1/z.
%    elimDelay(D)
%    elimDelay(D,inputdelays,outputdelays,internaldelays)

%	 Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:56 $
if D.Ts==0
    ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','elimDelay')
end
ni = nargin;
if ni==1
   id = D.Delay.Input;
   od = D.Delay.Output;
   fd = D.Delay.Internal;
end
if ni<5
   % logical vector locating the continuous-time initial
   %   state x0c among the vector of discrete states.
   icmap = true(size(D.a,1),1);
end
[ny,nu] = iosize(D);

% Internal delays
% RE: Always mapping all or none
if any(fd(:))
   % Build a state-space realization of diag(Z.^(-INNERDELAYS))
   nfd = length(fd);
   Df = localDelayModel(D.Delay.Internal,D.Ts);  
   % Absorb delay model
   icmap = [icmap ; false(sum(D.Delay.Internal),1)];
   D.Delay.Internal = zeros(0,1);
   D.Delay.Input(nu+nfd,1) = 0;
   D.Delay.Output(ny+nfd,1) = 0;
   D = lft(D,Df,nu+1:nu+nfd,ny+1:ny+nfd,1:nfd,1:nfd);
end

% Input delays
if any(id(:))
   % Build a state-space realization of diag(Z.^(-INPUTDELAYS))
   Din = localDelayModel(id,D.Ts);   
   % Connect in series
   icmap = [icmap ; false(sum(id),1)];
   Din.Delay.Input = D.Delay.Input - id;
   D.Delay.Input = zeros(nu,1);
   D = mtimes(D,Din);
end
   
% Output delays
if any(od(:))
   % Build a state-space realization of diag(Z.^(-OUTPUTDELAYS))
   Dout = localDelayModel(od,D.Ts);   
   % Connect in series
   icmap = [false(sum(od),1) ; icmap];
   Dout.Delay.Output = D.Delay.Output - od;
   D.Delay.Output = zeros(ny,1);
   D = mtimes(Dout,D);
end



%---------------------- Local Functions ----------------------

function Dss = localDelayModel(Delays,Ts)
% Constructs a state-space model for diag(z^(-DELAYS))
% where DELAYS is a vector of N delays.
n = length(Delays);
ns = sum(Delays);  % number of poles at z=0
idx = find(Delays);

% Build a state-space realization of diag(Z.^(-DELAYS))
a = zeros(ns);     b = zeros(ns,n);
c = zeros(n,ns);   d = eye(n);

% Loop over each channel
ptr = 0;
for ct=1:length(idx),
   j = idx(ct);
   k = Delays(j);   % j-th channel delayed by z^-k
   ast = ptr+1:ptr+k;    % assigned states
   a(ast,ast) = diag(ones(1,k-1),1);
   b(ast,j) = [zeros(k-1,1);1];
   c(j,ast) = [1,zeros(1,k-1)];
   d(j,j) = 0;
   ptr = ptr+k;
end

% Build delay model
Dss = ltipack.ssdata(a,b,c,d,[],Ts);
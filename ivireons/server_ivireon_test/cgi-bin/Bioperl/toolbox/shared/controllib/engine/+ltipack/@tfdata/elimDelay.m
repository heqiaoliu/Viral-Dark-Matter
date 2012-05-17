function [D,icmap] = elimDelay(D,varargin)
% Maps delays to 1/z
%    elimDelay(D)
%    elimDelay(D,inputdelays,outputdelays,iodelays)

%	 P. Gahinet 8-28-96
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:34 $
if D.Ts==0
    ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','elimDelay')
end
icmap = [];

% Collects I/O delays to be mapped to 1/z
[D,Tdio] = elimDelay@ltipack.ltidata(D,varargin{:});

% Map delays
idxDelay = find(Tdio);
if ~isempty(idxDelay)
   num = D.num;
   den = D.den;
   for ctx=1:length(idxDelay)
      ct = idxDelay(ctx);
      tau = Tdio(ct);
      num{ct} = [zeros(1,tau) num{ct}];
      den{ct} = [den{ct} zeros(1,tau)];
   end
   % Eliminate leading zeros in both num and den
   [D.num,D.den] = utRemoveLeadZeros(num,den);
end

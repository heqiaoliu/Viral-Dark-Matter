function [D,icmap] = elimDelay(D,varargin)
% Maps delays to 1/z

%	 P. Gahinet 8-28-96
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:29 $
if D.Ts==0
   ctrlMsgUtils.error('Control:transformation:FirstArgDiscreteModel','elimDelay')
end
icmap = [];

% Collects I/O delays to be mapped to 1/z
[D,Tdio] = elimDelay@ltipack.ltidata(D,varargin{:});

% Map delays
idxDelay = find(Tdio);
if ~isempty(idxDelay)
   for ctx=1:length(idxDelay)
      ct = idxDelay(ctx);
      D.p{ct} = [D.p{ct} ; zeros(Tdio(ct),1)];
   end
end

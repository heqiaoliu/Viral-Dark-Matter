function [D,icmap] = elimDelay(D,varargin)
% Absorbs specified subset of input, output, and IO delays 
% into the frequency response.
%    elimDelay(D)
%    elimDelay(D,inputdelays,outputdelays,iodelays)

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:19 $
icmap = [];

% Collects I/O delays to be absorbed in the response
[D,Tdio] = elimDelay@ltipack.ltidata(D,varargin{:});

% Absorb TDIO into frequency response
if any(Tdio(:))
   w = unitconv(D.Frequency,D.FreqUnits,'rad/s');
   Ts = D.Ts;
   if Ts>0
      w = w*Ts;
   end
   for ct=1:length(w)
      D.Response(:,:,ct) = exp(complex(0,-w(ct)*Tdio)) .* D.Response(:,:,ct);
   end
end

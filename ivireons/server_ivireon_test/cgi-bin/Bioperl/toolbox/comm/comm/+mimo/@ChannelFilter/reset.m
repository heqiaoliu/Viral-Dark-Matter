function reset(h, z)
%RESET  Reset channel filter object.
%   RESET(H) resets the state of a channel filter object.
%   RESET(H, Z) sets the initial tap gain values based on the path gain
%   vector Z.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:48 $

% Number of channel filter taps
nTaps = length(h.TapIndices);

L = length(h.PathDelays);

Nt = h.NumTxAntennas;
Nr = h.NumRxAntennas;
NL = Nt*Nr;

% If path gain vector specified, set channel filter tap gains.
if nargin==2
    Lt = nTaps;
    g = zeros(Lt*NL,1);
    for it = 1:Nt
        for ir = 1:Nr 
            idx = (it-1)*Nr + ir - 1;
            idxg = idx*Lt + (1:Lt);
            idxz = idx*L + (1:L);
            g(idxg,:) = h.AlphaMatrix.' * z(idxz,:);
        end
    end
    h.TapGains = g.';
end

% Reset channel filter state.
h.State = complex(zeros(1, nTaps*Nt));

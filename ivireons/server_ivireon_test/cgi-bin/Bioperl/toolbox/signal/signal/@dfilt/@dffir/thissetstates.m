function S = thissetstates(Hd,S)
%THISSETSTATES Overloaded set for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2006/06/27 23:34:15 $

if isempty(S),
    % Prepended the state vector with one extra zero per channel
    S = nullstate1(Hd.filterquantizer);
else
    % Check data type, quantize if needed
    S = validatestates(Hd.filterquantizer, S);
    % Prepended the state vector with one extra zero per channel
    S = prependzero(Hd.filterquantizer, S);
end

tapIndex = Hd.TapIndex;
if isempty(tapIndex),
    tapIndex = 0;
end
% Convert linear -> circular states 
[nr ncol] = size(S);
Scir = S;
Scir(tapIndex+1:end,:) = S(1:nr-tapIndex,:);
Scir(1:tapIndex,:) = S(nr-tapIndex+1:end,:);

Hd.HiddenStates = Scir;

S = [];


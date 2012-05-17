function S = thissetstates(Hm,S)
%THISSETSTATES Overloaded set for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/12/26 22:05:35 $

if isempty(S),
    Hm.HiddenStates = 0;
else
    Hm.HiddenStates = S;
end


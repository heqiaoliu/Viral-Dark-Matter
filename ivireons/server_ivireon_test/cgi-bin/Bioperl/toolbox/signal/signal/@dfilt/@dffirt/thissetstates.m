function S = thissetstates(Hd,S)
%THISSETSTATES Overloaded set for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:55:57 $

% Check data type, quantize if needed
S = validatestates(Hd.filterquantizer, S);

Hd.HiddenStates = S;
S = [];



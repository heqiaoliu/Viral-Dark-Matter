function S = getstates(Hm,S)
%GETSTATES Overloaded get for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:55:37 $

Scir = Hm.HiddenStates;

% Circular -> Linear
tapIndex = Hm.tapIndex+1; %1-based indexing
S = [Scir(tapIndex+1:end,:); Scir(1:tapIndex-1,:)];

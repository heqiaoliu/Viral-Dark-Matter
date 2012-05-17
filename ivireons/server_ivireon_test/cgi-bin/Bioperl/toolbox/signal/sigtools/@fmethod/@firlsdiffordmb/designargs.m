function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:44:39 $

order = hs.FilterOrder;

% Determine what type of differentiator we have
typeIV = true;
typeIII = false;
if ~rem(order,2),
    typeIII = true; 
    typeIV = false;
end

% Define the 2nd to last and last Amplitudes and Frequencies
if typeIV,
    endA = 1;
    stA  = hs.Fstop;
else
    endA = 0;
    stA  = 0;
end

args = {order, [0 hs.Fpass hs.Fstop 1], [0 hs.Fpass*pi stA*pi  endA*pi],...
    'differentiator'};

% [EOF]

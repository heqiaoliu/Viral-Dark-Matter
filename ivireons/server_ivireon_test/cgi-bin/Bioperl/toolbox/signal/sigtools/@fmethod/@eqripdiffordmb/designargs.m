function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:38:09 $

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
    error(generatemsgid('InvalidDesign'), ...
        'Only type III Differentiators can be designed with this specification.');
else
    endA = 0;
    stA  = 0;
end

args = {order, [0 hs.Fpass hs.Fstop 1], [0 hs.Fpass*pi stA*pi  endA*pi],...
    'differentiator'};

% [EOF]

function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:44:34 $

order = hs.FilterOrder;

if ~rem(order,2),
    error(generatemsgid('invalidSpec'), ...
    'Only type IV Differentiators can be designed with the FilterOrder specification.');
end

args = {order, [0 1], [0 pi],'differentiator'};

% [EOF]

function pv = blockparams(this, mapstates)
%BLOCKPARAMS   Return the block parameters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:34:55 $

% MAPSTATES is ignored because a gain doesn't have states.

pv  = scalarblockparams(this.filterquantizer);

pv.Gain = num2str(get(reffilter(this), 'Gain'));

% [EOF]

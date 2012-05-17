function pv = blockparams(this, mapstates)
%BLOCKPARAMS   Return the block parameters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/14 04:01:03 $

b = isspblksinstalled;
if b,
    % Use Signal Processing Blockset block
    pv.delay = sprintf('%d',this.Latency);
else
    pv.NumDelays = sprintf('%d',this.Latency);
end

% IC
if strcmpi(mapstates, 'on'),
    pv.IC = mat2str(getinitialconditions(this));
end

% [EOF]

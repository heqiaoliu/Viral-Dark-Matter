function hblk = multiportswitch(hTar, name, numinputs, zeroidx)
%MULTIPORTSWITCH Add a Multiport Switch block to the model.
%   HBLK = MULTIPORTSWITCH(HTAR, NAME, NUMINPUTS, ZEROIDX) adds a gain
%   block named NAME, sets its number of inputs to NUMINPUTS, set if zero
%   index is used or not according to ZEROIDX and returns a handle HBLK to
%   the block.
%

% Copyright 2004-2005 The MathWorks, Inc.

error(nargchk(3,4,nargin,'struct'));

hblk = add_block('built-in/MultiportSwitch', [hTar.system '/' name]);
% %note numinputs has to be a string. InputSameDt should be off. See g392853
% %for details
set_param(hblk, 'Inputs', numinputs,'InputSameDT','off');

if nargin == 4
    set_param(hblk, 'zeroidx', zeroidx);   %zeroidx is 'on' or 'off'
end


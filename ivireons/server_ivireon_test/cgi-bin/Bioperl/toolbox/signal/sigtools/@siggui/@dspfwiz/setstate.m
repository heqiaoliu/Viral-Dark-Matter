function setstate(this, state)
%SETSTATE   PreSet function for the 'state' property.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:21:09 $

% We no longer let them choose the blocktype.
if isfield(state, 'blocktype'), state = rmfield(state, 'blocktype'); end
if isfield(state, 'BlockType'), state = rmfield(state, 'BlockType'); end

siggui_setstate(this, state);

% [EOF]

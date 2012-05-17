function hilite(this,newState)
%HILITE  Highlight the connection and driver block
%   mode can be: 'on', 'off', or 'toggle'
%
%   Does NOT bring system forward/give it focus,
%   because that can cause other model blocks to blink
%   unnecessarily during a "flash" operation.

% Copyright 2005 The MathWorks, Inc.

if nargin<2, newState='on'; end

for indx = 1:length(this)
    lclHilite(this(indx), newState);
end

% -------------------------------------------------------------------------
function lclHilite(this, newState)

% newState should be either 'on' or 'off', so translate
% the 'toggle' state accordingly.
%
% Also, this.hiliteOn should reflect the new state
switch lower(newState)
    case 'toggle'
        % toggle current highlight state
        this.hiliteOn = ~this.hiliteOn;
        if this.hiliteOn
            newState='on';
        else
            newState='off';
        end
    case 'on'
        this.hiliteOn = true;
    case 'off'
        this.hiliteOn = false;
end

% Bring system forward/give it focus, but ONLY if
% we're turning on the hilite
%
% if this.hiliteOn, view(this.sysh(i)); end

% Highlight the blocks and lines
if ~checkConnection(this)
    return;
end

hilite(this.Block, newState);

if ishandle(this.Line)
    hilite(this.Line, newState);
end

% [EOF]

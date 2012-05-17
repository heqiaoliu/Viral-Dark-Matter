function select(this,newState)
%SELECT Select an output line (not the block) if present
%   SELECT('on') selects the signal in the Simulink system
%   SELECT('off') de-selects the signal in the Simulink system
%

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:07 $

if nargin < 2
    newState = 'on';
end

% Select the output lines
% Be careful to check for valid handles, since lines might
% not actually be connected to the block ports (-1 handles)
%
linesSelected=false;
for indx = 1:length(this)
    port = this(indx).Port;
    if ishandle(port.line)
        set(port.line,'selected',newState);
        linesSelected=true;
    end

    % Select blocks, but only if no lines were selected
    % This is for FLOATING scopes - if lines are selected, that's sufficient.
    % You don't want lines and blocks, since such a selection would normally
    % result in an error message (confusion for the scope)
    if ~linesSelected
        set(this.Block,'selected',newState);
    end
end

% [EOF]

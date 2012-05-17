function clearPersistentLines(this)
%CLEARPERSISTENTLINES Clear out any false lines from erasemode none.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:08:01 $

% When switching between processing modes, we need to refresh the erasemode
% in case it is not already normal. This only needs to be done for hg1.
if ~feature('hgusingmatlabclasses')
    oldEraseMode = get(this.Lines, 'EraseMode');
    
    % Set the erasemode to normal to clear persistent lines.
    set(this.Lines, 'EraseMode', 'normal');
    
    % Force a redraw in case no pause occurs.
    drawnow;
    
    % Set the line back.
    if iscell(oldEraseMode)
        oldEraseMode = oldEraseMode{1};
    end
    set(this.Lines, 'EraseMode', oldEraseMode);
end

% [EOF]

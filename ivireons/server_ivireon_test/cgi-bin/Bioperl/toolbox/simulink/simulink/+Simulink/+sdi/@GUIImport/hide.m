function hide(this)

    % Hide GUI without closing
    %
    % Copyright 2010 The MathWorks, Inc.

    set(this.HDialog, 'visible', 'off');
    drawnow;
end
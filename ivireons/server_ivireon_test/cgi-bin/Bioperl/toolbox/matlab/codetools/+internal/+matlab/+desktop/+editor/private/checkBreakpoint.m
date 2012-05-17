function checkBreakpoint(breakpoint)
%checkBreakpoint checks that the given variable is a com.mathworks.mde.editor.breakpoints.Breakpoint. 

% Copyright 2009 The MathWorks, Inc.

    if (~isa(breakpoint, 'com.mathworks.mde.editor.breakpoints.MatlabBreakpoint'))
        throw(MException('MATLAB:editor:NotABreakpoint', 'Breakpoint should be a com.mathworks.mde.editor.breakpoints.Breakpoint.'));
    end
end
function doSetBreakpoint(filename, requestedBreakpoint)
%setbreakpoint sets a breakpoint in the given file based on the contents of the given Java breakpoint.
%
%   This class is unsupported and might change or be removed without
%   notice in a future version. 

%   doSetBreakpoint(filename, requestedBreakpoint)
%     filename  is the MATLAB char array containg the file name to set the breakpoint in.
%     requestedBreakpoint the com.mathworks.mde.editor.breakpoints.Breakpoint
%                         from which to derive the inputs for the call to
%                         dbstop.

%   Copyright 2009 The MathWorks, Inc.

    import com.mathworks.mde.editor.breakpoints.MatlabBreakpoint;

    % ensure that the input arguments are of the expeted Java types.
    checkFilename(filename);
    checkBreakpoint(requestedBreakpoint);
  
    if (requestedBreakpoint.isAnonymous)
        doSetAnonymousBreakpoint(filename, requestedBreakpoint);
    else
        doSetLineBreakpoint(filename, requestedBreakpoint);
    end
end

% Utility methods.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function doSetAnonymousBreakpoint(filename, javaBreakpoint) 
% doSetAnonymousBreakpoint sets a MATLAB anonymous breakpoint from a Java Breakpoint.
    lineNumberString = int2str(javaBreakpoint.getOneBasedLineNumber);
    anonymousFunctionIndexString = int2str(javaBreakpoint.getAnonymousIndex);
    fullLineNumberString = [lineNumberString '@' anonymousFunctionIndexString];
    expressionString = char(javaBreakpoint.getWrappedExpression);
    dbstop(filename, fullLineNumberString, 'if', expressionString);
end

function doSetLineBreakpoint(filename, javaBreakpoint) 
% doSetLineBreakpoint sets a MATLAB line breakpoint from a Java Breakpoint.
    lineNumberString = int2str(javaBreakpoint.getOneBasedLineNumber);
    expressionString = char(javaBreakpoint.getWrappedExpression);
    dbstop(filename, lineNumberString, 'if', expressionString);
end

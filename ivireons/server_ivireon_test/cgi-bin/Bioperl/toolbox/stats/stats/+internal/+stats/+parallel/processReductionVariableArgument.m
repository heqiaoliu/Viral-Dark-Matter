function [fh, iv] = processReductionVariableArgument(arg)
%PROCESSREDUCTIONVARIABLEARGUMENT organizes reduction variables for SMARTFOR.
%
%   PROCESSREDUCTIONVARIABLEARGUMENT is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

% ARG is either a single struct or a single keyword
if isstruct(arg)
    if ~isa(arg.fh,'function_handle')
        % Errors in this function are toolbox development errors.
        % They should not occur in released code and not be
        % be visible to external users.
        error('stats:parallel:processReductionVariableArgument:BadFunctionHandle', ...
            'The first element in ARG is not a function handle.');
    end
    fh = arg.fh;
    iv = arg.iv;
else
    % find keyword match and create matching struct
    sz = size(arg);
    if strcmpi('argmin',arg)
        iv = {Inf,Inf,{}};
        fh = @internal.stats.parallel.pickSmaller;
    elseif strcmpi('argmax',arg)
        iv = {-Inf,Inf,{}};
        fh = @internal.stats.parallel.pickLarger;
    else
        error('stats:parallel:processReductionVariableArgument:BadArg', ...
            'ARG was neither a valid struct or keyword.');
    end
end
end %-processReductionVariableArgument


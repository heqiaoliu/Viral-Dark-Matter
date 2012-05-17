function clearvars(varargin)
%CLEARVARS  Clear variables from memory.
%   CLEARVARS removes all variables from the workspace.
%
%   CLEARVARS VAR1 VAR2 ... clears the variables specified. The wildcard
%   character '*' can be used to clear variables that match a pattern. For
%   instance, CLEARVARS X* clears all the variables in the current
%   workspace that start with X.
%
%   If any of these variables are global, CLEARVARS removes those variables
%   from the current workspace only, thus leaving them accessible to any
%   functions that declare them as global.
%
%   CLEARVARS -GLOBAL removes all global variables, including those made
%   global within functions.
%
%   CLEARVARS -GLOBAL VAR1 VAR2 ... completely removes the specified
%   global variables. 
%
%   The -GLOBAL flag may be used with any of the following syntaxes.  If
%   used, it must immediately follow the function name.
%
%   CLEARVARS -REGEXP PAT1 PAT2 ... clears all variables that match regular
%   expression patterns PAT1, PAT2, ...
%   For more information on using regular expressions, type "doc regexp" at
%   the command prompt. 
%
%   CLEARVARS -EXCEPT VAR1 VAR2 ... clears all variables except those
%   specified. The wildcard character '*' can be used to exclude variables
%   that match a pattern from being cleared. CLEARVARS -EXCEPT X* clears
%   all the variables in the current workspace except for those that start
%   with X, for instance.
%
%   CLEARVARS -EXCEPT -REGEXP PAT1 PAT2 ... clears all variables except
%   those that match regular expression patterns PAT1, PAT2, ...
%   If used in this way, the -REGEXP flag must immediately follow the
%   -EXCEPT flag.
%
%   CLEARVARS VAR1 VAR2 ... -EXCEPT -REGEXP PAT1 PAT2 ... can be used to
%   specify variables to clear that do not match specified regular
%   expression patterns.
%
%   CLEARVARS -REGEXP PAT1 PAT2 ... -EXCEPT VAR1 VAR2 ... clears variables
%   that match PAT1, PAT2, ..., except for variables VAR1, VAR2, ...
%
%   Examples:
%
%       % Clear variables starting with "a", except for the variable "ab"
%       clearvars a* -except ab
%
%       % Clear all global variables except those starting with "x"
%       clearvars -global -except x*
%
%       % Clear variables that start with "b" and are followed by 3 digits,
%       % except for the variable "b106"
%       clearvars -regexp ^b\d{3}$ -except b106
%
%       % Clear variables that start with "a", except those ending with "a"
%       clearvars a* -except -regexp a$
%
%   See also CLEAR, WHO, WHOS, PERSISTENT, GLOBAL.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/06 19:16:21 $

% Parse the input arguments.
[clearVarArgs, exceptVarArgs, flags] = parseArgs(varargin);

% Process clearVarArgs into a regular expression for use with CLEAR.
clearVarPat = createPattern(clearVarArgs, flags.regexpClear);

% If it is not empty, process exceptVarArgs into a regular expression for
% use with CLEAR.
if isempty(exceptVarArgs)
    exceptVarPat = '';
else
    exceptVarPat = sprintf('(?!%s)', createPattern(exceptVarArgs, flags.regexpExcept));
end

% Combine clearVarPat and exceptVarPat into one pattern.
clearPat = sprintf('^%s%s', exceptVarPat, clearVarPat);

% Create an expression for the CLEAR function, depending on whether the
% global flag was specified.
if flags.global
    globalStr = '''-global'', ';
else
    globalStr = '';
end
clearExpr = sprintf('clear(%s''-regexp'', ''%s'')', globalStr, clearPat);

% Call the clear expression in the caller's workspace using EVALIN.
evalin('caller', clearExpr);


function [clearVarArgs, exceptVarArgs, flags] = parseArgs(argCell)
% Parse input arguments, separating them into variables to be cleared,
% variables exempt from clearing, and flags.

% Initialize flags and indices.
exceptFlagIdx = [];
exceptFlagSpecified = false;
globalFlagSpecified = false;
regexpClearFlagSpecified  = false;
regexpExceptFlagSpecified = false;

% Parse the input for flags while verifying that each input is a char.
nArgs = length(argCell);
isVarArg = true(1, nArgs);
for argIdx = 1:nArgs
    
    currentArg = argCell{argIdx};
    
    % Verify that the argument is a char.
    validateattributes(currentArg, {'char'}, {}, mfilename, '', argIdx);
    
    % Check whether a flag was specified.
    if strncmp(currentArg, '-', 1)
        
        isVarArg(argIdx) = false;
        
        % Verify that a valid flag was specified.
        switch lower(currentArg)
            case '-except'
                % Error if the flag was specified earlier.
                % Otherwise, store where it was declared.
                if exceptFlagSpecified
                    error('MATLAB:clearvars:tooManyExceptFlags', ...
                          'The ''-except'' flag, which cannot be specified more than once, was specified for inputs %d and %d.', ...
                          exceptFlagIdx, argIdx);
                end
                exceptFlagSpecified = true;
                exceptFlagIdx = argIdx;
            case '-global'
                % Only honor the -global flag if it is the first argument.
                if argIdx == 1
                    globalFlagSpecified = true;
                else
                    issueFlagPositionWarning('global', argIdx);
                end
            case '-regexp'
                % Only honor the -regexp flag in the following cases:
                %  - it is the first argument.
                %  - it is the first argument following the -global flag.
                %  - it is the first argument following the -except flag.
                if argIdx == 1 || (globalFlagSpecified && argIdx == 2)
                    regexpClearFlagSpecified = true;
                elseif exceptFlagSpecified && argIdx == exceptFlagIdx+1
                    regexpExceptFlagSpecified = true;
                else
                    issueFlagPositionWarning('regexp', argIdx);
                end
            otherwise
                error('MATLAB:clearvars:unknownFlag', ...
                      'The flag ''%s'' is not recognized.  Type "help %s" to see what flags are supported.', ...
                      currentArg, mfilename);
        end
    end
end

% Now that the flags have been processed, remove them from the argument
% cell.  Also, group arguments into those occurring before the '-except'
% flag and those occurring after it.
if exceptFlagSpecified
    clearVarArgs  = argCell(isVarArg(1:exceptFlagIdx-1));
    isExceptVarArg = isVarArg;
    isExceptVarArg(1:exceptFlagIdx) = false;
    exceptVarArgs = argCell(isExceptVarArg);
else
    clearVarArgs = argCell(isVarArg);
    exceptVarArgs = {};
end

% Create the flag structure.
flags = struct('global', globalFlagSpecified, ...
               'regexpClear', regexpClearFlagSpecified, ...
               'regexpExcept', regexpExceptFlagSpecified);

function issueFlagPositionWarning(flagName, argIdx)
% Issue a warning about the positioning of the flag.
warnId = sprintf('MATLAB:clearvars:%sFlagIgnored', flagName);
warning(warnId, 'Input number %d specifying flag ''-%s'' is being ignored.  Type "help %s" to see the valid syntax.', ...
        argIdx, flagName, mfilename);

function pattern = createPattern(variableArgs, regexpFlagSpecified)
% Create regular expression depending on how many arguments were specified
% and whether a '-regexp' flag was specified.
if isempty(variableArgs)
    pattern = '.';
elseif regexpFlagSpecified
    pattern = sprintf('.*(%s)', joinCellArgs(variableArgs));
else
    variableArgs = regexptranslate('wildcard', variableArgs);
    pattern = sprintf('(%s)$', joinCellArgs(variableArgs));
end

function variableArgStr = joinCellArgs(variableArgs)
% Join cells depending on how many are present.
nVariableArgs = length(variableArgs);
if nVariableArgs > 1
    variableArgStr = [variableArgs{1}, ...
                      sprintf('|%s', variableArgs{2:end})];
else
    variableArgStr = variableArgs{1};
end

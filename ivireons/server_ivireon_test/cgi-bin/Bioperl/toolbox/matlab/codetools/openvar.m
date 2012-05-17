function openvar(name,array)
%OPENVAR Open workspace variable in tool for graphical editing
%   OPENVAR(NAME) edits the array in the base workspace whose name is given
%   in NAME.  NAME must contain a string.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2008/12/04 22:39:13 $

% Error handling
if nargin == 0 || isempty(name)
    error('MATLAB:openvar:VariableRequired', ...
        'The first argument to OPENVAR must be a valid variable name.');
end

if ~ischar(name)
    error('MATLAB:openvar:VariableNameAsString', ...
        'The first argument to OPENVAR must be a string.');
end

% Detecting undesirable arguments.  Warn for now, error in the future.
if findstr(name, ' ')
    warning('MATLAB:openvar:VariableNameContainsSpaces', ...
        ['Arguments to OPENVAR must not contain spaces.\n', ...
        'This will become an error in a future release.']);
    name(name == ' ') = [];
else
    first = min([findstr(name, '.'), findstr(name, '('), findstr(name, '{')]);
    if (isempty(first) || first == 1)
        first = length(name)+1;
    end
    if (isempty(name) || ~isvarname(name(1:first-1)))
        warning('MATLAB:openvar:InvalidVariableName', ...
            ['Arguments to OPENVAR must begin with a valid variable name.\n',...
            'This will become an error in a future release.']);
    end
end

errormsg = javachk('MWT', 'The Variable Editor');
if ~isempty(errormsg)
    error('MATLAB:openvar:UnsupportedPlatform', errormsg.message);
end

% Input argument validation is completed.  Proceed.
handled = false;

% If the variable under consideration is "elaborate", open appropriately.
try
    if (nargin > 1) && (isa(array, 'handle') || isa(array, 'opaque'))
        mthds = methods(array);
        if any(strcmp('dialog', mthds))
            array.dialog;
        elseif any(strcmp('getDialogSchema', mthds))
            DAStudio.Dialog(array);          
        else
            inspect(array);
        end
        handled = true;
    end
catch
    openVariableEditor(name);
end

% No one else was willing to edit.  Attempt editing in the Variable Editor.
if ~handled
    openVariableEditor(name);
end

function openVariableEditor(name)
com.mathworks.mlservices.MLArrayEditorServices.openVariable(name);

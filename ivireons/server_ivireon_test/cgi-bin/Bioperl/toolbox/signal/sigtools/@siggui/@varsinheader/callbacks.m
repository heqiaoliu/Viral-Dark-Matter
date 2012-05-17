function cbs = callbacks(hVars)
%CALLBACKS Callbacks for the varsinheader object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/06/17 12:55:21 $

cbs.name     = @name_cb;
cbs.length   = @length_cb;

% --------------------------------------------------------------------
function name_cb(hcbo, eventStruct, hVars)

% Get the current variables
vars = getcurrentvariables(hVars);

% Get the entered variable
indx = get(hcbo, 'userdata');
nvar = fixup_uiedit(hcbo);

if isvarname(nvar{1}) & ~isreserved(nvar{1}),
    
    % Save the entered variable
    vars.var{indx} = nvar{1};
    setcurrentvariables(hVars, vars);
else
    set(hcbo, 'String', vars.var{indx});
    
    nameerror(hVars, nvar{1})
end


% --------------------------------------------------------------------
function length_cb(hcbo, eventStruct, hVars)

% Get the current variables
vars = getcurrentvariables(hVars);

% Get the entered variable
indx = get(hcbo, 'UserData');
nvar = fixup_uiedit(hcbo);

if isvarname(nvar{1}),
    
    % Save the entered variable
    vars.length{indx} = nvar{1};
    setcurrentvariables(hVars, vars);
else
    set(hcbo, 'String', vars.length{indx});
    
    nameerror(hVars);
end


% --------------------------------------------------------------------
function nameerror(hVars, var)

if isreserved(var),
    endstr = ' is a reserved word.';
else
    endstr = ' is not a valid variable name.';
end

senderror(hVars, ['''' var '''' endstr]);

% [EOF]

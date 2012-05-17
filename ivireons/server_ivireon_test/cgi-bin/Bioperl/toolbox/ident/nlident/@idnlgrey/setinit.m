function setinit(nlsys, property, values)
%SETINIT  Sets the property (field) of InitialStates to values of an
%   IDNLGREY object.
%
%   SETINIT(NLSYS, PROPERTY, VALUES);
%
%   NLSYS: name of the variable representing IDNLGREY model. It must be a
%   valid variable name (not expression).
%
%   PROPERTY should be 'Name', 'Unit', 'Value', 'Minimum', 'Maximum', or 'Fixed'.
%
%   VALUES: Values for the chosen PROPERTY. Use cell array of Nx values, if
%   Nx>1 (Nx = number of initial states). For example:
%       SETINIT(NLSYS, 'Name', 'X1')          % if model has 1 state
%       SETINIT(NLSYS, 'Name', {'X1', 'X2'}); % if model has 2 states
%
%   Type "idprops idnlgrey initialstates" for more information on initial
%   states of an IDNLGREY model.
%
%   See also GETINIT, GETPAR, SETPAR, IDNLGREY.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:00 $
%   Written by Peter Lindskog.

% Check that the function is called with three input arguments.
nin = nargin;
error(nargchk(3, 3, nin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','setinit','IDNLGREY');
end

sysname = inputname(1);
if isempty(sysname)
    ctrlMsgUtils.error('Ident:general:setFirstInput','idnlgrey/setinit')
end

% Check that PROPERTY is a valid InitialStates field.
if (ndims(property) ~= 2) || ~ischar(property) || isempty(property) || (size(property, 1) ~= 1)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar1','setinit(NLSYS, PROPERTY, VALUE)');
else
    choices = {'Name' 'Unit' 'Value' 'Minimum' 'Maximum' 'Fixed'};
    choice = strmatch(lower(property), lower(choices));
    if isempty(choice)
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar2',property,'InitialStates','idnlgrey/setinit')
    elseif (length(choice) > 1)
        choices = {choices{choice}};
        choice = '';
        for j = 1:length(choices)
            choice = [choice(:)' '''' choices{j} ''', '];
        end
        ctrlMsgUtils.error('Ident:general:ambiguousOptWithInfo',property,choice(1:end-2))
    else
        property = choices{choice};
    end
end

Nx = length(nlsys.InitialStates);

% Check that PROPERTY can be set to VALUES.
switch (property)
    case {'Name' 'Unit'}
        % Check that property is a string or a cell array of strings.
        if ischar(values)
            values = {values};
        elseif ~iscellstr(values) || (length(values) ~= Nx)
            if Nx==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit1a',...
                    sprintf('setinit(NLSYS, ''%s'', VALUE)',property))
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit1b',...
                    sprintf('setinit(NLSYS, ''%s'', VALUES)',property),Nx)
            end
        end
    case {'Value' 'Minimum' 'Maximum'}
        if isnumeric(values)
            values = {values};
        elseif ~iscell(values) || (length(values) ~= Nx)
            if Nx==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit2a',...
                    sprintf('setinit(NLSYS, ''%s'', VALUE)',property))
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit2b',...
                    sprintf('setinit(NLSYS, ''%s'', VALUES)',property),Nx)
            end
        end
        
        if strcmp(property, 'Value')
            for i = 1:length(values)
                if ~isequal(size(values{i}),size(nlsys.InitialStates(i).Value))
                    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetInit1',i,i)
                end
            end
        end
    case 'Fixed'
        if islogical(values)
            values = {values};
        elseif ~iscell(values) || (length(values) ~= Nx)
            if Nx==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit4a','setinit(NLSYS, ''Fixed'', VALUE)')
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit4b','setinit(NLSYS, ''Fixed'', VALUES)',Nx)
            end
        end
end

% Set parameter property to values.
InitialStates = nlsys.InitialStates;
[InitialStates.(property)] = deal(values{:});
assignin('caller', sysname, pvset(nlsys, 'InitialStates', InitialStates));

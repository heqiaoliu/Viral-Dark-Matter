function setpar(nlsys, property, values)
%SETPAR  Sets the property (field) of Parameters to values of an IDNLGREY
%   object.
%
%   SETPAR(NLSYS, PROPERTY, VALUES);
%
%   NLSYS: name of the variable representing IDNLGREY model. It must be a
%   valid variable name (not expression).
%
%   PROPERTY should be 'Name', 'Unit', 'Value', 'Minimum', 'Maximum', or 'Fixed'.
%
%   VALUES: Values for the chosen PROPERTY. Use cell array of Np values, if
%   Np>1 (Np = number of model parameters). For example:
%       SETPAR(NLSYS, 'Name', 'Par1')           % if model has 1 parameter
%       SETPAR(NLSYS, 'Name', {'Par1', 'Par2'});% if model has 2 parameters
%
%   Type "idprops idnlgrey parameters" for more information on parameters
%   of an IDNLGREY model.
%
%   See also GETPAR, GETINIT, SETINIT, IDNLGREY.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:01 $
%   Written by Peter Lindskog.

% Check that the function is called with three input arguments.
nin = nargin;
error(nargchk(3, 3, nin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','setpar','IDNLGREY');
end

sysname = inputname(1);
if isempty(sysname)
    ctrlMsgUtils.error('Ident:general:setFirstInput','idnlgrey/setpar')
end

% Check that PROPERTY is a valid Parameters field.
if (ndims(property) ~= 2) || ~ischar(property) || isempty(property) || (size(property, 1) ~= 1)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar1','setpar(NLSYS, PROPERTY, VALUE)')
else
    choices = {'Name' 'Unit' 'Value' 'Minimum' 'Maximum' 'Fixed'};
    choice = strmatch(lower(property), lower(choices));
    if isempty(choice)
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar2',property,'Parameters','idnlgrey/setpar')
        
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

% Check that PROPERTY can be set to VALUES.
Np = length(nlsys.Parameters);
switch (property)
    case {'Name' 'Unit'}
        % Check that property is a string or a cell array of strings.
        if ischar(values)
            values = {values};
        elseif ~iscellstr(values) || (length(values) ~= Np)
            if Np==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit1a',...
                    sprintf('setpar(NLSYS, ''%s'', VALUE)',property))
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit1b',...
                    sprintf('setpar(NLSYS, ''%s'', VALUES)',property),Np)
            end
        end
    case {'Value' 'Minimum' 'Maximum'}
        if isnumeric(values)
            values = {values};
        elseif ~iscell(values) || (length(values) ~= Np)
            if Np==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit2a',...
                    sprintf('setpar(NLSYS, ''%s'', VALUE)',property))
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit2b',...
                    sprintf('setpar(NLSYS, ''%s'', VALUES)',property),Np)
            end
        end
        if strcmp(property, 'Value')
            for i = 1:length(values)
                if ~isequal(size(values{i}),size(nlsys.Parameters(i).Value))
                    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetPar1',i,i)
                end
            end
        end
    case 'Fixed'
        if islogical(values)
            values = {values};
        elseif ~iscell(values) || (length(values) ~= Np)
            if Np==1
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit4a',...
                    'setpar(NLSYS, ''Fixed'', VALUE)')
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySetParInit4b',...
                    'setpar(NLSYS, ''Fixed'', VALUES)',Np)
            end
        end
end

% Set parameter property to values.
Parameters = nlsys.Parameters;
[Parameters.(property)] = deal(values{:});
assignin('caller', sysname, pvset(nlsys, 'Parameters', Parameters));

function values = getpar(nlsys, property)
%GETPAR  Returns an Np-by-1 cell array with the specified property (field)
%   values of Parameters of an IDNLGREY object.
%
%   VALUES = GETPAR(NLSYS);
%   VALUES = GETPAR(NLSYS, PROPERTY);
%
%   PROPERTY should be 'Name', 'Unit', 'Value', 'Minimum', 'Maximum',
%   'Fixed'. When called with one input argument, PROPERTY will be 'Value'.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:51 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','getpar','IDNLGREY')
end

% Check that PROPERTY is a valid Parameters field.
if (nin < 2)
    property = 'Value';
elseif (ndims(property) ~= 2) || ~ischar(property) || isempty(property) || (size(property, 1) ~= 1)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar1','getpar(NLSYS, PROPERTY)')
else
    choices = {'Name' 'Unit' 'Value' 'Minimum' 'Maximum' 'Fixed'};
    choice = strmatch(lower(property), lower(choices));
    if isempty(choice)
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInitPar2',property,'Parameters','idnlgrey/getpar')
        
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

% Return specified property values.
values = {nlsys.Parameters.(property)}';

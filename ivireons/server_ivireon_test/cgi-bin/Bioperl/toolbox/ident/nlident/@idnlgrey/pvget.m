function [value, valuestr] = pvget(nlsys, property)
%PVGET  Get values of public IDNLGREY properties.
%
%   VALUES = PVGET(NLSYS) returns all public values in a cell array VALUES.
%
%   VALUE = PVGET(NLSYS, 'PROPERTY') returns the value of the single
%   property with name PROPERTY.
%
%   The function assumes that property holds the true case sensitive
%   property name.
%
%   For more information on IDNLGREY properties, type IDPROPS IDNLGREY.
%
%   See also IDNLMODEL/GET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2008/06/13 15:23:45 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two arguments.
nin  = nargin;
error(nargchk(1, 2, nin, 'struct'));
nout = nargout;

% Return the requested data.
if (nin == 1)
    % Return all public IDNLGREY property values.
    propnames = pnames(nlsys);
    value = cell(size(propnames));
    for i = 1:length(value)
        value{i} = pvget(nlsys, propnames{i});
    end
    if (nout > 1)
        valuestr = idpvformat(value);
    end
else
    % Return a single property.
    switch property
        case pnames(nlsys, 'specific')
            % IDNLGREY specific properties.
            value = nlsys.(property);
        otherwise
            % IDNLMODEL specific properties.
            value = pvget(nlsys.idnlmodel, property);
    end
    if (nout > 1)
        valuestr = idpvformat({value});
    end
end
function init(this, name, type, value, status)
%INIT     Initialize the property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/09 19:32:52 $

this.Name = name;

% Create dynamic property for Value, since the type is
% passed as an argument and not known to the schema
schema.prop(this, 'Value', type);

if nargin>3
    % This could cause an error if Type and Value are mismatched
    this.Value = value;
end
if nargin>4
    this.Status = status;
end

% [EOF]

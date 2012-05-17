function schema
%SCHEMA for scalar class.

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:45 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'scalar',findclass(pk,'requirement'));

%Native public properties
p = schema.prop(c,'isConstraint','bool');
p.FactoryValue = true;
p = schema.prop(c,'isMinimized','bool');
p.FactoryValue = false;
p = schema.prop(c,'RequirementWeight','double');
p.FactoryValue = 1;

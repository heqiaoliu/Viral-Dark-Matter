function schema
%SCHEMA for generic save object

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:40 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'saveobject',findclass(pk,'requirement'));

%% Class properties
p = schema.prop(c, 'class', 'string');  
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c, 'fldData', 'MATLAB array');  
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';

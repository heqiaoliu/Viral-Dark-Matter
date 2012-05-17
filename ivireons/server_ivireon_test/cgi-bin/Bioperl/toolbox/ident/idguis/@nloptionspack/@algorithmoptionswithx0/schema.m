function schema
% SCHEMA  Class definition for ALGORITHMOPTIONSWITHX0

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:04:25 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

hParentClass = findclass(hCreateInPackage,'algorithmoptions');

% Construct class
c = schema.class(hCreateInPackage, 'algorithmoptionswithx0',hParentClass);

if isempty( findtype('IdnlhwInitTypes') )
  schema.EnumType( 'IdnlhwInitTypes', {'Zero','Estimate'});
end

schema.prop(c,'Initial_State','IdnlhwInitTypes');
%p.FactoryValue = 'Zero';

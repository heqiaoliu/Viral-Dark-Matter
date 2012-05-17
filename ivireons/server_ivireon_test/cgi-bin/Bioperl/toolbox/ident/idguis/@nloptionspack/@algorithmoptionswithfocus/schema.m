function schema
% SCHEMA  Class definition for ALGORITHMOPTIONSWITHFOCUS

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:26 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

hParentClass = findclass(hCreateInPackage,'algorithmoptions');

n0 = idnlarx([2 2 1],'tree');

% Construct class
c = schema.class(hCreateInPackage, 'algorithmoptionswithfocus',hParentClass);

if isempty( findtype('IdFocusTypes') )
  schema.EnumType( 'IdFocusTypes', {'Prediction','Simulation'});
end

p = schema.prop(c,'Estimation_Focus','IdFocusTypes');
p.FactoryValue = n0.Focus;

p = schema.prop(c,'Iterative_Wavenet','IterWavenet');
p.FactoryValue = 'Auto';

function schema

% Copyright 2005 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codetext');

% Public properties
schema.prop(cls,'Text','MATLAB array');
p = schema.prop(cls,'Ignore','MATLAB array');
set(p,'FactoryValue',false);




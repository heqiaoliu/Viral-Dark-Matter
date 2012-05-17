function schema

% Copyright 2006 The MathWorks, Inc.

% Used by MAKEMCODE to insure unique function names.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'functiontable');

% Public properties
schema.prop(cls,'FunctionList','MATLAB array');
p = schema.prop(cls,'FunctionNameList','MATLAB array');
set(p,'FactoryValue',cell(0));
schema.prop(cls,'FunctionNameListCount','MATLAB array');
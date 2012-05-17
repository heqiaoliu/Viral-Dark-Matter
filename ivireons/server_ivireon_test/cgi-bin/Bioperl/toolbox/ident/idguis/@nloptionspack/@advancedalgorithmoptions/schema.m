function schema
% SCHEMA  Defines properties for advancedalgorithmoptions class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:18 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'advancedalgorithmoptions');

n0 = idnlarx([1 1 1],'tree');

options = n0.Algorithm.Advanced;

f = fieldnames(options);
v = struct2cell(options);
for  k=1:length(f)
    p = schema.prop(c,f{k},'double');
    p.FactoryValue = v{k};
end

p = schema.prop(c,'Listeners','MATLAB array');
p.Visible = 'off';

p = schema.prop(c,'Parent','MATLAB array');
p.Visible = 'off';

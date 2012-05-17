function schema
% SCHEMA  Defines properties for advancedtree class

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:54:19 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'advancedtree');

w = treepartition;
options = w.Options;
f = fieldnames(options);
v = struct2cell(options);
for  k=1:length(f)
    if ~any(strcmpi(f{k},{'FinestCell','Threshold'}))
        p = schema.prop(c,f{k},'double');
    else
        p = schema.prop(c,f{k},'MATLAB array');
    end
    p.FactoryValue = v{k};
end

p = schema.prop(c,'Listeners','MATLAB array');
p.Visible = 'off';

p = schema.prop(c,'Parent','MATLAB array');
p.Visible = 'off';

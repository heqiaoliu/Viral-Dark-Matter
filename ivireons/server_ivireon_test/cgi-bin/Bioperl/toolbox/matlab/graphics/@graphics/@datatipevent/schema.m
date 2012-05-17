function schema

% Copyright 2006 The MathWorks, Inc.

% Construct class
pk = findpackage('graphics');
cls = schema.class(pk,'datatipevent');

schema.prop(cls,'Target','MATLAB array');
schema.prop(cls,'Position','MATLAB array');
p = schema.prop(cls,'DataIndex','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'DataTipHandle','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls,'InterpolationFactor','MATLAB array');
set(p,'Visible','off');
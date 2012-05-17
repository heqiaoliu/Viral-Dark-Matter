function schema
% brush class: This class provides access to properties of the
% datalink state in MATLAB

%   Copyright 2007 The MathWorks, Inc.

cls = schema.class(findpackage('graphics'),'linkdata');

p = schema.prop(cls,'Enable','on/off');
p.AccessFlags.PublicSet = 'off';

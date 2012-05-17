function schema
% SCHEMA  Defines properties for advancedwavenet class.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:54:20 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'advancedwavenet');

w = wavenet;
options = w.Options;
f = fieldnames(options);
v = struct2cell(options);
for k=1:length(f)
    if ~strcmpi(f{k},'FinestCell')
        p = schema.prop(c,f{k},'double');
    else
        p = schema.prop(c,f{k},'MATLAB array');
    end
    p.FactoryValue = v{k};
    %p.SetFunction = @(es,ed) LocalSetFunction(es,ed,f{k});
end

p = schema.prop(c,'Listeners','MATLAB array');
p.Visible = 'off';

p = schema.prop(c,'Parent','MATLAB array');
p.Visible = 'off';

%p = schema.prop(c,'jPropViewInspector','com.mathworks.toolbox.ident.nnbbgui.NonlinPropInspector');
%p.Visible = 'off';

%{
%--------------------------------------------------------------------------
function val = LocalSetFunction(es,ed,Name,varargin)
%Name, ed
es.Object
%disp(es.Object.Options.(Name))
val = ed;
%}

%{
import com.mathworks.mlwidgets.inspector.*,
p=PropertyView;
a=nloptionspack.advancedwavenet;
p.setObject(a);
import javax.swing.*,
F=JFrame;
F.getContentPane.add(p);
F.pack;
F.show
%}
function schema
%SCHEMA  Definition of @HSVPlotOptions 
% Options for @timeplot

%  Author(s): C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:29 $

% Register class 
pkg = findpackage('plotopts');
c = schema.class(pkg, 'HSVPlotOptions', findclass(pkg, 'PlotOptions'));

% Public attributes
p = schema.prop(c, 'YScale', 'MATLAB array');  
p.setFunction = @localSetScale;
p.FactoryValue = 'linear';

p = schema.prop(c, 'AbsTol', 'double');  
p.FactoryValue = 0;

p = schema.prop(c, 'RelTol', 'double');  
p.FactoryValue = 1e-8;

p = schema.prop(c, 'Offset', 'double');  
p.FactoryValue = 1e-8;



function v = localSetScale(this,v)
% Validates input
if iscell(v)
   v = v{1};
end
if ~any(strcmp(v,{'linear','log'}))
    ctrlMsgUtils.error('Controllib:plots:ScaleProperty1','YScale');
end
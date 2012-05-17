function schema
%SCHEMA defines the LEGEND schema
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2005/06/21 19:29:23 $ 

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'legend' , pkgHG.findclass('axes'));

p = schema.prop(h,'TextHandle','handle');
p = schema.prop(h,'String', 'NStrings');
p = schema.prop(h,'PositionMode', 'NReals'); %should be 'double' but there is a bug in doubles
p = schema.prop(h,'Interpreter', 'string');
p = schema.prop(h,'LegendStrings','MATLAB array');
% "Positioned by Legendpos" this property is used to control whether or not 
% ud.legendpos (a.k.a. PositionMode) is updated when the
% Position property listener function
% (changedPosition) fires. 
p = schema.prop(h,'PosByLegendpos','on/off');


pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
%pl.AccessFlags.PublicGet = 'off';

pl = schema.prop(h, 'StringChangedListener', 'handle vector');
pl.AccessFlags.Serialize = 'off';
%pl.AccessFlags.PublicGet = 'off';
    

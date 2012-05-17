function schema
%SCHEMA defines the LEGENDLINE schema
%
%  See also LEGEND, GRAPH2D.LEGEND, GRAPH2D.LEGENDPATCH

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2005/06/21 19:29:25 $ 

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'legendline' , pkgHG.findclass('line'));

p = schema.prop(h,'LineHandle','handle');

p = schema.prop(h,'LegendMarkerHandle','handle');

p = schema.prop(h,'DisplayMarker','string'); %should be enum
p = schema.prop(h,'DisplayMarkerSize','NReals'); %should be double
p = schema.prop(h,'DisplayMarkerEdgeColor','MATLAB array'); %should be color with auto/none
p = schema.prop(h,'DisplayMarkerFaceColor','MATLAB array'); %should be color with auto/none

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';

pl = schema.prop(h, 'LegendStyleListener', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';


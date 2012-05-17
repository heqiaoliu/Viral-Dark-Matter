function h = plotpair(hndl)
% Returns instance of @plotpair class.
%
%   H = PLOTARRAY(AXHANDLE) creates a 2-by-1 plot array using 
%   the HG axes instances supplied in AXHANDLE.

%   Author: P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:01 $

h = ctrluis.plotpair;
hndl = handle(hndl);

% Create missing axes
if length(hndl)==1
   hndl = [hndl ; ...
         handle(axes('Parent',hndl.Parent,'Visible','off', ...
         'units', 'normalized','ContentsVisible','off'))];
end
h.Axes = hndl(:);

% Position in Normalized units
Pos = hgconvertunits(ancestor(hndl(1),'figure'), ...
    hndl(1).position, hndl(1).units, 'normalized', hndl(1).parent);

% Geometry
% VerticalGap: vertical spacing in pixels
% HeightRatio: relative heights of 1st and 2nd axes (sum = 1)
g = h.Geometry;
g.VerticalGap = 14;
g.HeightRatio = [.53 .47];
h.Geometry = g;

% Row and column visibility
h.ColumnVisible = true;
h.RowVisible = true(2,1);
h.Position = Pos;

% REVISIT: Make axes a bit smaller than plot area so that SUBPLOT does not delete hidden
% phase axes in BODEMAG (see geck 122758)
NormUnits = strcmp(get(hndl,'Units'),'normalized');
for ct = 1:length(hndl)
    if ~NormUnits(ct)
        Units = hndl(ct).Units;
        hndl(ct).Units = 'Normalized';
    end
    set(hndl(ct),'Position',[Pos(1:2) 0.5*Pos(3:4)])
    if ~NormUnits(ct)
        hndl(ct).Units = Units;
    end
end

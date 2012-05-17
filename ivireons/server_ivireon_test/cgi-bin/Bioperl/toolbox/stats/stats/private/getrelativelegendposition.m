function relpos=getrelativelegendposition(fig,axh,legh)
%GETRELATIVELEGENDPOSITION Get (x,y) coords of legend center relative to axes

% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:40 $
% Copyright 1993-2004 The MathWorks, Inc.

if nargin<1 || isempty(fig)
   fig = gcf;
end
if nargin<2 || isempty(axh)
   axh = get(fig,'CurrentAxes');
end
if nargin<3 || isempty(legh)
   legh = legend(axh);
end

legloc = get(legh,'Location');
if isequal(legloc,'none')
   % Get the center of the legend in pixels
   oldu = get(legh,'units');
   legpos = get(legh,'position');
   legpos = hgconvertunits(fig,legpos,oldu,'pixels',fig);
   pctr = [legpos(1)+legpos(3)/2, legpos(2)+legpos(4)/2];

   % Get the position of the axes in pixels
   oldu = get(axh,'units');
   axpos = get(axh,'position');
   axpos = hgconvertunits(fig,axpos,oldu,'pixels',fig);

   % Compute a normalized position relative to the axes
   relpos = (pctr - axpos(1:2)) ./ axpos(3:4);
else
   relpos = legloc;
end

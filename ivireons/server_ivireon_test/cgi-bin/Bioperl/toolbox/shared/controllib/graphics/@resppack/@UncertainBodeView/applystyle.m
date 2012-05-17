function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line style to @view objects.
%
%  Applies line style to all gobjects making up the @view instance
%  (as returned by GHANDLES).

%  Author(s): C. Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:14 $

Curves = ghandles(this);

for ct1 = 1:size(Curves,1)
   for ct2 = 1:size(Curves,2)
      [Color] = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      c = Curves(ct1,ct2,:);
      Color = localGetColor(Color);
      if strcmpi(this.UncertainType,'Bounds')
          set(c(ishandle(c)),'FaceColor',Color,'EdgeColor',Color,...
              'FaceAlpha',.8)
      else
          set(c(ishandle(c)),'Color',Color)
      end
   end
end



function Color = localGetColor(Color)

hsvcolor = rgb2hsv(Color);
Color = hsv2rgb(hsvcolor+[0,-.8,0]);
function dfdupfigure(dffig)
%DFDUPFIGURE Make a duplicate, editable copy of the distribution fitting figure

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:48 $
%   Copyright 2003-2006 The MathWorks, Inc.

% Copy the regular axes, not the legend axes
f = figure;
ax = findall(dffig,'Type','axes','Tag','main');
copyobj(ax,f);
newax = findall(f,'Type','axes','Tag','main');

% Adjust layout in new figure, but don't add axis controls
dfadjustlayout(f,'off');

for i=1:length(ax)
   % Remove any context menus and callbacks associated with the old figure
   set(findall(newax(i),'Type','line'),...
       'DeleteFcn','','UIContextMenu',[],'ButtonDownFcn','');

   % Make a new legend based on the original, if any
   [legh,unused,h0,txt] = legend(ax(i));
   if length(h0)>0
      c0 = get(ax(i),'Child');
      c1 = get(newax(i),'Child');
      h1 = h0;
      remove = false(size(h1));
      for j=1:length(h0)
         k = find(c0==h0(j));
         if isempty(k)
            remove(j) = true;
         else
            % Convert to lineseries 
            h1(j) = hgline2lineseries(c1(k(1)));
         end
      end
      h1(remove) = [];
      txt(remove) = [];
      legpos = getrelativelegendposition(dffig,ax(i),legh);
      leginfo = dfgetlegendinfo(legh);
      newlegh = legend(newax(i),h1,txt,leginfo{:});
      setrelativelegendposition(legpos,f,newax(i),newlegh);         
      set(newlegh,'Interpreter','none');
   end
end

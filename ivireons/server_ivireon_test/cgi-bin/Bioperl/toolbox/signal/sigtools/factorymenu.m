function [h, children] = factorymenu(arg,newparent)
%FACTORYMENU Render default (factory) menus. 
%   FACTORYMENU(MENU_NAME,NEWFIGURE) returns handles to default 
%   figure menus and renders them on NEWFIGURE.

%   Author(s): W. York 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2008/05/31 23:27:37 $ 

f = figure('Visible','off','menubar','figure');
if ischar(arg)
    arg = [upper(arg(1)) lower(arg(2:end))];
    hlist = findall(f,'type','uimenu','label',arg);
    if isempty(hlist)
        hlist = findall(f,'type','uimenu','label',['&' arg]);
    end
else
    % get the first uimenu with the requested position
    % make sure it's not a child menu.
    hlist = findall(f,'type','uimenu','position',arg);
    indices = false;
    for i=1:length(hlist)
        indices(i) = isempty(get(hlist(i),'children'));
    end
    hlist = hlist(indices);
    hlist = hlist(1);
end

h = copyobj(hlist,newparent);
children = copyobj(flipud(findall(f,'parent',hlist)),h);
close(f);

% [EOF]

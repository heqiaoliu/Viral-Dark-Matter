function str = iterdisplay(this)
% STR = ITERDISPLAY(THIS)

%   Author(s): John Glass
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2007/10/15 23:31:33 $

if ~isempty([this.F_dx(:);this.F_y(:);this.F_const(:)])
    [element,type,max_val] = getLimitingConstraint(this);
    
    if usejava('Swing') && desktop('-inuse') && feature('hotlinks') && strcmp(type,'block')
        str1 = sprintf('hilite_system(''%s'',''find'');',element);
        str2 = 'pause(1);';
        str3 = sprintf('hilite_system(''%s'',''none'');',element);

        str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,element);
    else
        str1 = element;
    end
    str = {sprintf('(%0.5e) %s',max_val,str1)};
else
    str = {xlate('There are no constraints to meet.')};
end
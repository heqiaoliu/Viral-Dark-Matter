function showrootcs

% Copyright 2004-2005 The MathWorks, Inc.

me = daexplr;
mi = DAStudio.imMenuItem;
mi.setMenuItem(me, '');
mi.ItemID = 'VIEW_ROOTCONFIGSET';
if ~mi.On
  mi.execute;
end
cs = getActiveConfigSet(0);
me.view(cs);
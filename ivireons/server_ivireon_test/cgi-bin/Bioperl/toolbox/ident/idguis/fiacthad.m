function [index,cindex]=fiacthad
%FIACTHAD Finds the selected data sets.

%   L. Ljung 4-4-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2006/06/20 20:08:09 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
sumb=findobj(allchild(0),'flat','tag','sitb30');
models=findobj([XID.sumb(1);sumb(:)],'tag','dataline');

ind=findobj(models,'flat','linewidth',3);
cind=findobj(models,'flat','linewidth',0.5);
if isempty(ind)
   iduistat('No data sets selected. Click on data icons to select desired ones.')
end
index=[];
cindex=[];
for kh=ind(:)'
    tag=get(get(kh,'parent'),'tag');
    index=[index,eval(tag(6:length(tag)))];
end
for kh=cind(:)'
    tag=get(get(kh,'parent'),'tag');
    cindex=[cindex,eval(tag(6:length(tag)))];
end

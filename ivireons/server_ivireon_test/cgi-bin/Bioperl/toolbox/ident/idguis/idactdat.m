function actmod = idactdat(type)
%IDACTDAT Finds the selected data sets of a certain type/class.
% ACTMOD is a cell array of all selected data sets on the data
% board that are of class TYPE. If TYPE is omitted, all data sets are
% returned
 

%   L. Ljung 25-8-2006
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/09/30 00:19:25 $

alc = allchild(0);
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

sumb=findobj(alc,'flat','tag','sitb30');

models=findobj([XID.sumb(1);sumb(:)],'tag','dataline');
ind=findobj(models,'flat','linewidth',3);
actmod ={};
for k = 1:length(ind)
    mod = get(ind(k),'Userdata');
    if nargin == 0 || (nargin ==1 && isa(mod,type) )
            actmod = [actmod,{mod}];
    end
end
 
 

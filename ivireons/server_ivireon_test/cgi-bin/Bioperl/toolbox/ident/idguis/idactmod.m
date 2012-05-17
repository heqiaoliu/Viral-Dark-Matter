function actmod = idactmod(type)
%IDACTMOD Finds the selected models of a certain type/class.
% ACTMOD is a cell array of all selected models on the model
% board that are of class TYPE. If TYPE is omitted, all models are
% returned
 

%   L. Ljung 25-8-2006
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/09/30 00:19:26 $

alc = allchild(0);
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

sumb=findobj(alc,'flat','tag','sitb30');

models=findobj([XID.sumb(1);sumb(:)],'tag','modelline');
ind=findobj(models,'flat','linewidth',3);
actmod ={};
for k = 1:length(ind)
    mod = get(ind(k),'Userdata');
    if nargin == 0 || (nargin ==1 && isa(mod,type) )
            actmod = [actmod,{mod}];
    end
end
 
 

function [M,isActive,Colors] = getAllModels(Type,NamesOnly)
%Find all models in all model boards of a selected type.
% If Type is not specified or is empty ([],''), then all models are
% returned.
% If NamesOnly is TRUE, only a cell array of modelo names is returned,
% rather than actual objects.
% isActive: is model active or not (bool array)
% Colors: colors of lines associated with each model in model board.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/10/31 06:13:27 $

if nargin<2
    NamesOnly = false;
end

%M = {};
alc = allchild(0);
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
sumb = findobj(alc,'flat','tag','sitb30'); %all extra model boards

models = findobj([XID.sumb(1);sumb(:)],'tag','modelline','vis','on');
if nargout>1
    lw = get(models,{'lineWidth'}); lw = cat(1,lw{:});
    isActives = (lw>0.5);
    Cols = get(models,{'Color'});
end
actmod = {};
actmodnames = {};
isActive = true(0);
Colors = {};
for k = 1:length(models)
    mod = get(models(k),'Userdata');
    if ~isempty(Type) && ~isa(mod,Type)
        continue;
    end
    %if NamesOnly,mod = mod.Name;end
    actmod = [actmod,{mod}];
    actmodnames = [actmodnames, {mod.Name}];
    if nargout>1
        isActive(end+1) = isActives(k);
        Colors = [Colors;Cols{k}];
    end
end

%protect against accidental duplicate names
[unique_names,I,J] = unique(actmodnames);
if length(I)<length(actmodnames)
    actmod = actmod(I);
    actmodnames = unique_names;
end

if NamesOnly
    M = actmodnames;
else
    M = actmod;
end

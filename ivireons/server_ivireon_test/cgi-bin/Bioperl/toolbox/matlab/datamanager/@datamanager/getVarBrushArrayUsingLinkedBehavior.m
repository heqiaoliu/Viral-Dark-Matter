function I = getVarBrushArrayUsingLinkedBehavior(h,pos,bobj,objH,region,lastregion,extendMode,mfile,fcnname)

% Obtains a logical array the same size as a subreferenced linked variable
% representing data brushed by the specified region for cases where the
% linked variable is represnted by a graphic object with a link behavior object.

%   Copyright 2010 The MathWorks, Inc.

% Get the existing variable brushing array after accounting for subreferences
% for this graphic object
linkFigureStruct = h.Figures(pos);
brushMgr = datamanager.brushmanager;
gObjInd = find(linkFigureStruct.LinkedGraphics==objH);
I = brushMgr.getBrushingProp(linkFigureStruct.VarNames{gObjInd,2},...
    mfile,fcnname,'I');
subsStr = linkFigureStruct.SubsStr{gObjInd,2};
if ~isempty(I) && ~isempty(subsStr)
    Isubs = eval(['I' subsStr ';']);
else
    Isubs = I;
end

% Find logical arrays the same size as the sub-referenced linked variable
% representing expanded/constracted points
if length(region)==4 % RIO brushing
    Icurrent = false(size(Isubs));
    Icurrent(feval(bobj.LinkBrushFcn{1},bobj,region,objH,bobj.LinkBrushFcn{2:end})) = true;
    if ~isempty(lastregion)
        Ilast = false(size(Isubs));
        Ilast(feval(bobj.LinkBrushFcn{1},bobj,...
           lastregion,objH,bobj.LinkBrushFcn{2:end})) = true;                        
        Iextend= Icurrent & ~Ilast;
        Icontract = ~Icurrent & Ilast;
    else
        Iextend = Icurrent;
        Icontract = [];
    end
elseif length(region)==2 % Single click brushing
    Iextend = feval(bobj.LinkBrushFcn{1},bobj,region,objH,bobj.LinkBrushFcn{2:end});
    Icontract = [];
elseif isempty(region)
    Iextend = false(size(Isubs));
    Icontract = [];
end

% Set the variable brushing array for the newly selected region
if ~extendMode
    Isubs(Iextend) = true;
    Isubs(Icontract) = false;                
else
    Isubs(Iextend) = ~Isubs(Iextend);
    Isubs(Icontract) = ~Isubs(Icontract); 
end
if ~isempty(I) && ~isempty(subsStr)
    eval(['I' subsStr ' = Isubs;']);
else
    I = Isubs;
end
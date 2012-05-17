function linkedFigStruct = updateLinkedGraphics(h,I)

% Copyright 2008-2010 The MathWorks, Inc.

% Callback for graphic changes in linked plots which update
% linkplotmanager.

linkedFigStruct = [];
if isempty(I)
    return
end
if isempty(h.Figures)
    return
end
if ishghandle(I,'figure')
    I = find(I==[h.Figures.Figure]);
    if isempty(I)
        return
    end
end
f = h.Figures(I);

% Find graphic objects which can support linking (but may have empty data
% source properties)
gObj = findobj(f.Figure,'-property','YDataSource','-or','-property',...
    'XDataSource','-or','-property','ZDataSource');
gObj = findobj(gObj,'flat','BeingDeleted','off');
if feature('HGUsingMATLABClasses')
    gCustom = findobj(f.Figure,'-isa','hg2.DataObject',...
        '-and','-not',{'Behavior',struct},...
       '-function',@localHasLinkedBehavior);
else
    gCustom = findobj(f.Figure,...
        '-and','-not',{'Behavior',struct},...
       '-function',@localHasLinkedBehavior);    
end
gCustom = findobj(gCustom,'flat','BeingDeleted','off');

h.Figures(I).IsEmpty = isempty(gObj) && isempty(gCustom);
for k=length(gCustom):-1:1
    bobj(k) = hggetbehavior(gCustom(k),'linked'); 
    bEnable(k) = bobj(k).Enable; 
    bDataSource{k} = bobj(k).DataSource;
end

% Identify linked graphics
linkedNonCustomGraphics = handle(findobj(gObj,'flat','-function',...
                              @(x) ~isempty(get(x,'YDataSource')) || ...
                              ~isempty(get(x,'XDataSource')) || ...
                              ~isempty(get(x,'ZDataSource'))));
if ~isempty(gCustom)
    linkedCustomGraphics = handle(gCustom(~cellfun('isempty',bDataSource) & bEnable));
    if any(~bEnable)
        linkedNonCustomGraphics = setdiff(linkedNonCustomGraphics,handle(gCustom(~bEnable)));
    end
else
    linkedCustomGraphics = [];
end
linkedGraphics = [linkedNonCustomGraphics(:);linkedCustomGraphics(:)];
if ~feature('HGUsingMATLABClasses')
    needsLinkDataErrorProp = find(handle(linkedGraphics),'-not','-property','LinkDataError'); %#ok<GTARG>
    for k=1:length(needsLinkDataErrorProp)
        schema.prop(needsLinkDataErrorProp(k),'LinkDataError','MATLAB array');
    end            
else   
    hasLinkDataErrorProp = handle(findobj(linkedGraphics,'-property','LinkDataError'));
    if length(hasLinkDataErrorProp)<length(linkedGraphics)
        for k=1:length(linkedGraphics)
            if ~any(hasLinkDataErrorProp==linkedGraphics(k))
                addprop(linkedGraphics(k),'LinkDataError');
            end
        end 
    end
end
h.Figures(I).LinkedGraphics = linkedGraphics;

% Update current variable list
varNames = cell(length(linkedGraphics),3);
subsStr = cell(length(linkedGraphics),3);
numRegularObjs = length(linkedGraphics)-length(linkedCustomGraphics);
for k=1:numRegularObjs
    [varNames{k,1},subsStr{k,1}] = localExtractVarName(get(linkedGraphics(k),'XDataSource'));    
    [varNames{k,2},subsStr{k,2}] = localExtractVarName(get(linkedGraphics(k),'YDataSource'));
    if ~isempty(findprop(handle(linkedGraphics(k)),'ZDataSource'))
        [varNames{k,3},subsStr{k,3}] = localExtractVarName(get(linkedGraphics(k),'ZDataSource'));
    end
end
for k=1:length(linkedCustomGraphics)
    [varNames{k+numRegularObjs,2},subsStr{k+numRegularObjs,2}] = ...
        localExtractVarName(get(hggetbehavior(linkedCustomGraphics(k),'Linked'),'DataSource'));
end

% If plotting over a linked figure with un-linked graphics -> go out of
% linked mode
if ~isempty(h.Figures(I).VarNames) && isempty(varNames)
    fig = h.Figures(I).Figure;
    h.rmFigure(h.Figures(I).Figure);
    linkdata(fig,'off');
    return
end
h.Figures(I).VarNames = varNames;
h.Figures(I).SubsStr = subsStr;

% Signal that LinkPlotManager linkedGraphics are up to date
h.Figures(I).Dirty = false;

linkedFigStruct = h.Figures(I);

function [varName,subsstr] = localExtractVarName(expstr)

% Extract a potential variable name from the contents of a DataSource
% property. Most general from is X.Y(...)

expstr = strtrim(expstr);     
parenPos = strfind(expstr,'(');
if ~isempty(parenPos)
    subsstr = strtrim(expstr(parenPos:end));
    expstr = expstr(1:parenPos-1);
    % substr must be of the form (*)
    if length(subsstr)<=2 || subsstr(1)~='(' || subsstr(end)~=')'
        varName = '';
        subsstr = '';
        return
    end
    % Screen out the substrings which must be expression.
    % Strip the word "end" from the substr
%     substr_tmp = subsstr;
%     ind = strfind(subsstr,'end');
%     I = [];
%     for k=1:length(ind);
%         I = [I,ind(k):ind(k)+2];
%     end
%     substr_tmp(I) = [];
%     % If the stripped substring has letters in it it must be an expression.
%     if ~isempty(regexp(substr_tmp,'[a-z]','once'))
%         varName = '';
%         subsstr = '';
%         return
%     end
else
    subsstr = '';
end

expstrArfterLastPeriod =  expstr;
dotPos = strfind(expstrArfterLastPeriod,'.');
if ~isempty(dotPos)
    expstrArfterLastPeriod = expstrArfterLastPeriod(dotPos(end)+1:end);
end
if ~isvarname(expstrArfterLastPeriod)
    varName = '';
    subsstr = '';
else
    varName = expstr;
end

function state = localHasLinkedBehavior(h)

state = ~isempty(hggetbehavior(h,'linked','-peek'));


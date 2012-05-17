function [axesCount,fitschecked,bfinfo, ...
        evalresultsstr,evalresultsxstr,evalresultsystr,currentfit,coeffresidstrings] = ...
    bfitgetcurrentinfo(datahandle)
% BFITGETCURRENTINFO

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2006/05/27 18:07:56 $

fighandle = get(get(datahandle,'parent'),'parent');
axesCount = getappdata(fighandle,'Basic_Fit_Fits_Axes_Count');
fitschecked = getappdata(double(datahandle),'Basic_Fit_Showing');

evalresults = getappdata(double(datahandle),'Basic_Fit_EvalResults');
format = '%10.3g';
evalresultsstr = evalresults.string;
if isempty(evalresults.x)
    evalresultsxstr = '';
else   
    evalresultsxstr = cellstr(num2str(evalresults.x,format));
end
if isempty(evalresults.y)
    evalresultsystr = '';
else
    evalresultsystr = cellstr(num2str(evalresults.y,format));
end

currentfit = getappdata(double(datahandle),'Basic_Fit_NumResults_');

allcoeff = getappdata(double(datahandle),'Basic_Fit_Coeff');
allresids = getappdata(double(datahandle),'Basic_Fit_Resids');

if ~isempty(currentfit)
    resid = allresids{currentfit+1};
    % Ignore NaNs when calculating norm of resids
    coeffresidstrings = ...
      bfitcreateeqnstrings(datahandle,currentfit, ...
      allcoeff{currentfit+1},norm(resid(~isnan(resid))));
else
    coeffresidstrings = '';
end

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
guistatecell = struct2cell(guistate);
bfinfo = [guistatecell{:}];
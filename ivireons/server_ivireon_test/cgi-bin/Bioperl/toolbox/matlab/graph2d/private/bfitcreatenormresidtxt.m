function residnrmTxtH = bfitcreatenormresidtxt(residaxesH,residfigH,datahandle,fitsshowing)
% BFITCREATENORMRESIDTXT Add to plot the text norm of residuals for Basic Fitting GUI.

%   Copyright 1984-2008 The MathWorks, Inc.  
%   $Revision: 1.17.4.7 $  $Date: 2009/01/29 17:16:32 $

residnrmTxtH = [];

n = length(fitsshowing);
if n==0 ||  isempty(residaxesH) % no fits plotted OR no residuals plotted
    return
end

if ishghandle(residfigH)
    bfitlistenoff(residfigH);
end

allresids = getappdata(double(datahandle),'Basic_Fit_Resids');
txt = cell(n,1);
for i = 1:n
    % get fit type
    fittype = fitsshowing(i)-1;
    % add string to matrix
    resid = allresids{fitsshowing(i)};
    % ignore NaNs when calculating norm
    txt{i,:} = residtxtstring(fittype,norm(resid(~isnan(resid))));
end

% check hold state and save it
fignextplot = get(residfigH,'nextplot');
axesnextplot = get(residaxesH,'nextplot');
axesunits = get(residaxesH,'units');
set(residfigH,'nextplot','add');
set(residaxesH,'nextplot','add');
set(residaxesH,'units','normalized');

residnrmTxtH = getappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle');
if ~isempty(residnrmTxtH)
    delete(residnrmTxtH);
end
residnrmTxtH=text(.05, .95, txt,'parent',residaxesH, ...
    'tag', 'norm of residuals', ...
    'verticalalignment','top', ...
    'units', 'normalized');

%handle code generation for this text object in bfitMCodeConstructor.m
b = hggetbehavior(residnrmTxtH,'MCodeGeneration');
set(b, 'MCodeIgnoreHandleFcn', 'true');
    
% reset plot: hold and units
set(residfigH,'nextplot',fignextplot);
set(residaxesH,'nextplot',axesnextplot);
set(residaxesH,'units',axesunits);

bfitlistenon(residfigH)

%-------------------------------------------------------
function s = residtxtstring(fit,resid)
% RESIDTXTSTRING Create the text with norm of residuals.

switch fit
case 0
    s = sprintf('Spline: norm of residuals = 0');
case 1
    s = sprintf('Shape-preserving: norm of residuals = 0');
case 2
    s = sprintf('Linear: norm of residuals = %s', num2str(resid));
case 3
    s = sprintf('Quadratic: norm of residuals = %s', num2str(resid));
case 4
    s = sprintf('Cubic: norm of residuals = %s', num2str(resid));
otherwise
    s = sprintf('%dth degree: norm of residuals = %s', fit-1, num2str(resid));
end


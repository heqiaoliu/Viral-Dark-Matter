function bfitsavefit(datahandle, fit)
% BFITSAVEFIT Save a fit, as a struct, and the norm of resids to the workspace. 
%
%   BFITSAVEFIT(DATAHANDLE, FIT) saves the coefficients and type of FIT for data 
%   DATAHANDLE 

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2006/05/27 18:08:03 $

coeff = getappdata(double(datahandle),'Basic_Fit_Coeff');
bfresids = getappdata(double(datahandle),'Basic_Fit_Resids');
resids = bfresids{fit+1};

% ignore NaNs when calculating norm of resids
normvalue = norm(resids(~isnan(resids)));
fitvalue.type = fittype(fit);
fitvalue.coeff = coeff{fit+1};

checkLabels = {'Save fit as a MATLAB struct named:', ...
               'Save norm of residuals as a MATLAB variable named:', ...
               'Save residuals as a MATLAB variable named:'};
defaultNames = {'fit','normresid','resids'};
items = {fitvalue, normvalue, resids};
export2wsdlg(checkLabels, defaultNames, items, 'Save Fit to Workspace');

%------------------------------------------------------
function s = fittype(fit)
% FITTYPE Create fit type string.

switch fit
case 0
    s = 'spline';
case 1
    s = 'shape-preserving';
otherwise
    s = ['polynomial degree ',num2str(fit-1)];
end

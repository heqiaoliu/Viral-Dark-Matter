function bfitsaveresults(datahandle)
% BFITSAVERESULTS Save evaluated results of a fit to the workspace. 
%
%   BFITSAVERESULTS(DATAHANDLE)saves the x values evaluated of current fit of 
%   data DATAHANDLE to the base workspace.  

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/07/12 18:09:54 $

evalresults = getappdata(double(datahandle),'Basic_Fit_EvalResults');
xvalue = evalresults.x;
yvalue = evalresults.y;

checkLabels = {'Save X in a MATLAB variable named:', ...
               'Save f(X) in a MATLAB variable named:'};
defaultNames = {'x', 'fx'};
items = {xvalue, yvalue};

export2wsdlg(checkLabels, defaultNames, items, 'Save Results to Workspace');

function [x_str,y_str] = bfitevalfitbutton(datahandle,fit, expression, plotresultson, clearresults)
% BFITEVALFITBUTTON Interpolate/extrapolate using expression for fit.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.17.4.4 $  $Date: 2009/01/29 17:16:37 $

if nargin < 5
    clearresults = 0;
end
if clearresults
    x = []; y = []; errmsg = []; 
else
    [x,y,errmsg] = bfitevalfit(expression,datahandle,fit);
end
dh = double(datahandle);
if ishghandle(dh)
    evalresults = getappdata(dh,'Basic_Fit_EvalResults');
    evalresults.x = x; % x that we eval over (x = expression)
    evalresults.y = y; % y = f(x) that we eval over (x = expression)
    evalresults.string = expression;
    % evalresults.handle will get set in bfitcheckplotresults below
    % so we don't want to overwrite that handle since we'll need to delete
    % the old one.
    if ~isfield(evalresults,'handle')
        evalresults.handle = [];
    end
    setappdata(dh,'Basic_Fit_EvalResults',evalresults);
end
if isempty(errmsg)
    format = '%10.3g';
    x_str = cellstr(num2str(x,format));
    y_str = cellstr(num2str(y,format));
else
    x_str = {''};
    y_str = {''};
end
if ishghandle(dh)
    bfitcheckplotresults(plotresultson,datahandle,fit);
end

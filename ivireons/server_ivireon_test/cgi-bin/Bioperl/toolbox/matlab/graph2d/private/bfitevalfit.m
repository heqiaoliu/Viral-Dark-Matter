function [X,Y,errmsg] = bfitevalfit(expression,datahandle,fit)
% BFITEVALFIT evaluates a fit.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.14.4.5 $  $Date: 2009/01/29 17:16:36 $

X = []; 
Y = []; 
errmsg = '';

try
    % make into array in case a list of numbers
    X = evalin('base',['[' expression ']']);
catch err
    errmsg = sprintf('%s\n%s\n\n%s',...
        'Attempt to evaluate expression in MATLAB base workspace', ...
        ' failed with the following error:', err.message);
    bfitcascadeerr(errmsg, 'Basic Fitting');
    return
end

if ~isa(X, 'double')
    X=[];  % reset so that closing, then reopening does not error.
	errmsg = 'Expression must evaluate to a real scalar, vector, or matrix.';
    bfitcascadeerr(errmsg, 'Basic Fitting');
    return
end

if ~isreal(X)
    warnmsg = sprintf('Imaginary part of expression ignored.');
    warndlg(warnmsg,sprintf('Basic Fitting'));
    lastwarn(warnmsg);
    X = real(X);
end
dh = double(datahandle);
if ~ishghandle(dh)
	errmsg = 'Evaluating the expression caused the fit to be deleted.';
    bfitcascadeerr(errmsg, 'Basic Fitting');
    return

end
coeffcell = getappdata(dh,'Basic_Fit_Coeff'); % cell array of pp structures
pp = coeffcell{fit+1};

if isempty(pp)
    error('MATLAB:bfitevalfit:NoFit', 'No fit to evaluate.')
end

X = X(:);
% Calculate with "newX" but return with "X": (what we plot, etc with)
guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
if guistate.normalize
    newX  = (X - normalized(1))./(normalized(2));
else
    newX = X;
end
switch fit
case {0,1} % spline or pchip
    Y = ppval(pp,newX);
otherwise
    Y = polyval(pp,newX);
end
Y = Y(:);


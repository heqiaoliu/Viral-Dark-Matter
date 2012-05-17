function [errmsg,x,values] = dfevaluate(fitNames,x,fun,wantBounds,confLevel,plotFun)
%DFEVALUATE Evaluate fits for DFITTOOL

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:49 $
%   Copyright 1993-2009 The MathWorks, Inc.

% If the function is the empty string, clear the plot (if there is one) and
% clear any saved data.
if isempty(fitNames)
    dfevaluateplot(false); % closes the plot window
    dfgetset('evaluateResults', []);
    return
end
    
nfits = length(fitNames);
try
    x = sprintf('[ %s ]', x); % allow an unbracketed list of numbers to work
    x = evalin('base',x);
    if ~isnumeric(x)
        error('stats:dfittool:BadX','X must be a numeric value.');
    end
    confLevel = evalin('base',confLevel) ./ 100;
    if ~isnumeric(confLevel) || ~isscalar(confLevel) || ~(confLevel>0 && confLevel<1)
        error('stats:dfittool:BadConfLevel', ...
              'Confidence level must be a number between 0 and 100.');
    end
catch ME
    x = [];
    values = zeros(0, nfits*(1+2*wantBounds));
    errmsg = sprintf('Invalid MATLAB expression: %s',ME.message);
    return
end
errmsg = '';

x = x(:);
n = length(x);

% % This is enforced by the evaluate panel.
% switch fun
% case {'pdf' 'hazrate' 'condmean'}
%     % No bounds allowed for pdf, hazrate, or conditional mean.
%     wantBounds = false;
% otherwise % {'cdf' 'icdf' 'survivor' 'cumhazard' 'probplot'}
%     % bounds are allowed
% end   

% Output table will have first column for data, then for each fit, one
% column for function, two columns for bounds (if requested).
values = repmat(NaN, n, nfits*(1+2*wantBounds));

fitdb = getfitdb;
for i = 1:nfits
    fit = find(fitdb, 'name', fitNames{i});
    % Cannot compute bounds for kernel smooths and certain parametric fits.
    getBounds = wantBounds && ...
        (~isequal(fit.fittype, 'smooth') && fit.distspec.hasconfbounds);

    % Evaluate the requested function for this fit.
    try
        if getBounds
            [y,ylo,yup] = eval(fit,x,fun,confLevel);
            values(:,3*i-2) = y;
            values(:,3*i-1) = ylo;
            values(:,3*i) = yup;
        else
            y = eval(fit,x,fun);
            if wantBounds
                values(:,3*i-2) = y;
            else
                values(:,i) = y;
            end
        end
    catch ME
       errmsg = sprintf('Error evaluating fit: %s',ME.message);
    end
end

% Save the results for SaveToWorkSpace.  The plot function can be called
% directly from java, so it uses those saved results as well.
dfgetset('evaluateResults', [x,values]);

% Save information about the fits that we've evaluated for the plot function.
dfgetset('evaluateFun', fun);
dfgetset('evaluateInfo', struct('fitNames',{fitNames}, 'wantBounds',wantBounds));

dfevaluateplot(plotFun);

function fig = bfitfindresidfigure(fitfig, figtag)
% BFITFINDRESIDFIGURE is used to find the figure containing Basic Fitting residuals 
%
% It should be used only by private Basic Fitting and Data Stats 
% functions. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/29 17:16:39 $

% If a Basic Fitting figure is opened after having been saved, it will have
% the same 'Basic_Fit_Fig_Tag' identifier as the original figure until
% Basic Fitting is opened on it. Therefore check for an additional property
% that will only appear on the original figure

potentialfigures = findobj(0,'Basic_Fit_Fig_Tag', figtag);
if length(potentialfigures) > 1
    % Basic_Fit_Resid_Figure is set only when resids are on a separate
    % figure; otherwise the resid figure is the same as the fit figure
    fig = fitfig;
    for i=1:length(potentialfigures)
        if ishghandle(potentialfigures(i)) && ...
                ~isempty(bfitFindProp(potentialfigures(i), 'Basic_Fit_Resid_Figure'))
            fig = potentialfigures(i);
            break;
        end
    end
else
    fig = potentialfigures;
end
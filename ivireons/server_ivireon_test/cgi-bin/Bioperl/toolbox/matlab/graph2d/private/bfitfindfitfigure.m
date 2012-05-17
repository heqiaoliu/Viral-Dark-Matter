function fig = bfitfindfitfigure(figtag)
% BFITFINDFITFIGURE is used to find a Basic Fitting or Data Stats figure 
%
% It should be used only by private Basic Fitting and Data Stats 
% functions. 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/29 17:16:38 $

% If a Basic Fitting figure is opened after having been saved, it will have
% the same 'Basic_Fit_Fig_Tag' identifier as the original figure until
% Basic Fitting is opened on it. Therefore check for an additional property
% that will only appear on the original figure

potentialfigures = findobj(0,'Basic_Fit_Fig_Tag', figtag);
if length(potentialfigures) > 1
    fig = [];
    for i=1:length(potentialfigures)
        if ishghandle(potentialfigures(i)) && ...
                ~isempty(bfitFindProp(potentialfigures(i), 'Basic_Fit_GUI_Object'))
            fig = potentialfigures(i);
            break;
        end
    end
else
    fig = potentialfigures;
end
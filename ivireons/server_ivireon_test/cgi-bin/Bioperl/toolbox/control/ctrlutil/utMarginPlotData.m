function [Gm,Pm,Wcg,Wcp,Dm] = utMarginPlotData(Gm,Pm,Wcg,Wcp,Dm)
% Utility to clean up minimum margins plots.
% Assumes margin data is scalar (return of min margins)

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:48:37 $

% Clean up for margins for plots
if isnan(Wcg)
    Gm = NaN;
end
if isnan(Wcp)
    Pm = NaN;
    Dm = NaN;
end

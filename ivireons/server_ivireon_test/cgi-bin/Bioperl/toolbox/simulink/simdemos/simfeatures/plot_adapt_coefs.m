function plot_adapt_coefs(block, ei) %#ok<INUSD>
%  
% Callback function for plotting the current adaptive filtering
% coefficients.  

% Copyright 2004-2009 The MathWorks, Inc.

hFig  = get_param(block.BlockHandle,'UserData');
tAxis = findobj(hFig, 'Type','axes');

tAxis = tAxis(2);
tLines = findobj(tAxis, 'Type','Line');

est = block.Dwork(2).Data;

set(tLines(3),'YData',est);


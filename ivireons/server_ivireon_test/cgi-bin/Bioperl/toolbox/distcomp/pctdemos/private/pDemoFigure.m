function fig = pDemoFigure()
%PDEMOFIGURE return a handle to a figure that can be used for 
%the Parallel Computing Toolbox demos.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:08:00 $

tag = 'pctDemoFigure';

fig = findobj('Tag', tag); 
if isempty(fig)
    fig = figure;
    set(fig, 'Tag', tag);
end

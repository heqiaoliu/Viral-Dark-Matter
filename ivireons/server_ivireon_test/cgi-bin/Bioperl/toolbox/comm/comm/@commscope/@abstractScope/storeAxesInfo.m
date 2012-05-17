function storeAxesInfo(this, hAxesRe, hAxesIm)
%STOREAXESINFO Store information of the current axes of the scope

%   @commscope/@abstractScope
%
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:11:06 $

% Store Title and labels.  Do not store Z-grid since it is handled by the
% type of the plot.
axesInfo.Title{1} = get(get(hAxesRe, 'Title'), 'String');
axesInfo.XLabel{1} = get(get(hAxesRe, 'XLabel'), 'String');
axesInfo.YLabel{1} = get(get(hAxesRe, 'YLabel'), 'String');
axesInfo.Tag{1} = get(hAxesRe, 'Tag');
axesInfo.XGrid{1} = get(hAxesRe, 'XGrid');
axesInfo.YGrid{1} = get(hAxesRe, 'YGrid');
axesInfo.XColor{1} = get(hAxesRe, 'XColor');
axesInfo.YColor{1} = get(hAxesRe, 'YColor');
axesInfo.ZColor{1} = get(hAxesRe, 'ZColor');

% If there is an imaginary axes
if this.PrivOperationMode
    axesInfo.Title{2} = get(get(hAxesIm, 'Title'), 'String');
    axesInfo.XLabel{2} = get(get(hAxesIm, 'XLabel'), 'String');
    axesInfo.YLabel{2} = get(get(hAxesIm, 'YLabel'), 'String');
    axesInfo.Tag{2} = get(hAxesIm, 'Tag');
    axesInfo.XGrid{2} = get(hAxesIm, 'XGrid');
    axesInfo.YGrid{2} = get(hAxesIm, 'YGrid');
    axesInfo.XColor{2} = get(hAxesIm, 'XColor');
    axesInfo.YColor{2} = get(hAxesIm, 'YColor');
    axesInfo.ZColor{2} = get(hAxesIm, 'ZColor');
else
    axesInfo.Title{2} = '';
    axesInfo.XLabel{2} = '';
    axesInfo.YLabel{2} = '';
    axesInfo.Tag{2} = '';
    axesInfo.XGrid{2} = '';
    axesInfo.YGrid{2} = '';
    axesInfo.XColor{2} = '';
    axesInfo.YColor{2} = '';
end

this.PrivAxesInfo = axesInfo;
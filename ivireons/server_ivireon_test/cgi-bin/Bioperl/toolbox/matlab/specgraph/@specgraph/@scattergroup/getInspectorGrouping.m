function [retval] = getInspectorGrouping(hThis,arg) %#ok
% Undocumented method. This may change in a future release.

%   Copyright 2006 The MathWorks, Inc.

% Called by the inspect.m for property grouping
retval = [];
if nargin<2
    arg = '';
end

if strcmp(arg,'-cellarray')
    info{1}{1} = 'Data';
    info{1}{2} = {'CData','CDataSource','XData','XDataSource','YData',...
                  'YDataSource','ZData','ZDataSource',...
                  'SizeData','SizeDataSource'};

    info{2}{1} = 'Style/Appearance';
    info{2}{2} = {'DisplayName','LineWidth','Marker',...
                  'MarkerEdgeColor','MarkerFaceColor'};

    info{3}{1} = 'Control';
    info{3}{2} = {'HitTestArea'};
    
    retval = info;
end
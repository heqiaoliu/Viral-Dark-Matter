function varargout = sf_hier_print2(varargin)
%   Manages Stateflow hierarchical printing and associated Simulink interfaces
%   for new unified editors (sramaswa, Jan 2010)
%   This is a modified copy of sf_hier_print that the old editor's print
%   pipeline uses

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/05 23:02:11 $


error(nargchk(2,3,nargin));

arg = '';
viewObjId = varargin{1};
cmdEvent = varargin{2};

if(nargin == 3)
    arg = varargin{3};
end

out = broadcast_l(viewObjId, cmdEvent, arg);

if(nargout > 0)
    varargout{1} = out;
end
%--------------------------------------------------------------------
function  out = broadcast_l(viewObjId, cmdEvent, arg)
%
%
%
out = '';
switch (cmdEvent),
    case 'start',         start_or_stop_sf_based_print(viewObjId, 'start');
    case 'stop',          start_or_stop_sf_based_print(viewObjId, 'stop');
    case 'getSystems',    out = get_systems_l(viewObjId, arg);
    otherwise,            error('Stateflow:UnexpectedError','bad args passed to sf_hier_print2()');
end
%--------------------------------------------------------------------
function start_or_stop_sf_based_print(viewObjId, action)
%
%
%

persistent chartParentSys;
persistent chartParentSysPaperOrientation;
persistent chartParentSysDirtyFlag;
persistent resetParentSysOrientation;

if(strcmpi(action,'start'))
    portal  = acquire_print_portal;
    sf('set', portal, '.sfBasedPrintJob', 1, '.viewObject', viewObjId, '.visible', 0);
    
    if(sf('get', viewObjId, '.isa') ~= 1) % Not a chart
        chartId = sf('get', viewObjId, '.chart');
    else
        chartId = viewObjId;
    end
    
    % OK, we need to do some massaging here, before we bring up the Print
    % Dialog.
    % The paper orientation of the chart might not be the same as the
    % parent (i.e the block diagram or the subsystem that contains this
    % chart). Check that first and if they are not the same, set the
    % paper-orientation of the system to be the same as chart and then
    % bring up the print dialog. This the workaround to fix geck 321917
    % (sramaswa, Oct 2nd 2006)
    block = get_chart_block_path_l(chartId);
    chartParentSys   = get_param(block, 'parent');
    chartPaperOrientation = get_param(block,'PaperOrientation');
    chartParentSysPaperOrientation = get_param(chartParentSys,'PaperOrientation');
    resetParentSysOrientation = false;
    if(~strcmpi(chartPaperOrientation,chartParentSysPaperOrientation))
        chartParentSysDirtyFlag = get_param(bdroot(chartParentSys),'Dirty');
        set_param(chartParentSys,'PaperOrientation',chartPaperOrientation);
        resetParentSysOrientation = true;
    end
    
    % sf('Private', 'simprintdlg', sys);
else
    assert(strcmpi(action,'stop'),'Invalid action');
    if(resetParentSysOrientation)
        set_param(chartParentSys,'PaperOrientation',chartParentSysPaperOrientation);
        set_param(bdroot(chartParentSys),'Dirty',chartParentSysDirtyFlag);
    end
    
    portal  = acquire_print_portal;
    sf('set', portal, '.sfBasedPrintJob', 0);
end
%--------------------------------------------------------------------
function systems = get_systems_l(sys, arg)
%
%
%
portal     = acquire_print_portal;
chart      = sf('get', portal, '.chart');
viewObj    = sf('get', chart, '.viewObj');
chartBlock = get_chart_block_path_l(chart);

printDirective = arg;

switch printDirective,
    case 'This',
        systems = {chartBlock};
        sf('set', portal, '.printStack', viewObj);
    case 'Up',
        %
        % If we're looking at a subchart, add all intermediate
        % views up to the chart itself
        %
        subcharts = [];
        while ~isequal(viewObj, chart),
            subcharts = [viewObj, subcharts]; %#ok<AGROW>
            viewObj = sf('get', viewObj, '.subviewer');
        end
        sf('set',portal, '.printStack', [chart, subcharts]);
        subchartPaths = {chartBlock};
        num = length(subcharts) + 1;
        subchartPaths = subchartPaths(ones(num,1));
        systems = [sys; subchartPaths];
        
    case 'Down',
        %
        % Get all types of SF objects under viewObj and add viewObj
        % plus the objects to printStack.
        %
        subcharts = non_empty_subcharts_in(viewObj);
        truth_tables = truth_tables_in(viewObj);
        eml_fcns = eml_fcns_in(viewObj);
        all_print_objects = [subcharts truth_tables eml_fcns];
        sf('set', portal, '.printStack', [viewObj, all_print_objects]);
        num = length(all_print_objects) + 1;
        systems = {chartBlock};
        systems = systems(ones(1, num));
        
    otherwise, error('Stateflow:UnexpectedError','bad args passed to sf_hier_print()');
end
%--------------------------------------------------------------------
function block = get_chart_block_path_l(chart)
%
%
%
instance = sf('get', chart, '.instance');
blockH   = sf('get', instance, '.simulinkBlock');
block    = getfullname(blockH);

% [EOF]


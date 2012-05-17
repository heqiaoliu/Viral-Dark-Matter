function varargout = is_sf_chart_block(blockFullNameOrHandle)

% Copyright 2002 The MathWorks, Inc.

error(nargoutchk(1, 2, nargout));

isSfChartBlock = false;
blockH = 0;
chartId = 0;

%m3i_info.chart = [];
%m3i_info.diagram = [];
m3i_info = [];

if(isnumeric(blockFullNameOrHandle) && isscalar(blockFullNameOrHandle) && ...
        ishandle(blockFullNameOrHandle))
    blockH = blockFullNameOrHandle;
elseif(ischar(blockFullNameOrHandle))
    blockName = find_system(blockFullNameOrHandle, 'searchdepth',0, 'type', 'block', 'masktype','Stateflow');
    if(~isempty(blockName) && length(blockName) == 1)
        blockH = get_param(blockName{1},'Handle');
    end
end

if(length(blockH) == 1 && blockH > 0 && ishandle(blockH))
    chartId = block2chart(blockH);
    if(~isempty(chartId))
        isSfChartBlock = is_sf_chart(chartId);
    end
end

if(nargout > 0)
    varargout{1} = isSfChartBlock;
end

if(nargout > 1)
    if(isSfChartBlock)
        %m3i_info.chart = StateflowDI.Factory.createNewModel;
        %m3i_info.chart.bootStrap(chartId);
        %subviewers = m3i_info.chart.subviewer;
        %m3i_info.diagram = subviewers.at(1);
        m3i_info = StateflowDI.Util.getSubviewer(chartId);
    end
    varargout{2} = m3i_info;
end

% [EOF]

function this = CovSubSysTree(callerSource)

% Copyright 2010 The MathWorks, Inc.


modelH = callerSource.modelH;
this = SlCov.CovSubSysTree;
this.m_callerSource = callerSource;

h = find_system(modelH, 'SearchDepth',1,'BlockType', 'SubSystem');
this.m_treeItems = {get_param(modelH, 'Name'), get_subsys(h)}; 

function ncarr = get_subsys(handles)
    ncarr = {};
    if isempty(handles)
        return;
    end

    for idx = 1:numel(handles)
        h = find_system(handles(idx), 'SearchDepth',1,'BlockType', 'SubSystem');
        tcarr = get_subsys(h(2:end));
        ncarr = [ncarr {get_param(handles(idx), 'Name'), tcarr}]; %#ok<AGROW>
    end
    
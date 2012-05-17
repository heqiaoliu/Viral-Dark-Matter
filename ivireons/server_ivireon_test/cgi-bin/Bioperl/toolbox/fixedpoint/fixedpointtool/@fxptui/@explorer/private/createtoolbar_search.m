function tb = createtoolbar_search(h, varargin)
%CREATETOOLBAR_SEARCH   

%   Author(s): V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/29 17:11:11 $

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;	
	tb = am.createToolBar(h);
end

action = am.createToolBarText(tb);
action.setText(DAStudio.message('FixedPoint:fixedPointTool:labelShow')); 
tb.addWidget(action);

searchComboBox = am.createToolBarComboBox(tb);
searchComboBox.setEditable(0);
searchComboBox.insertItems(0,{...
    DAStudio.message('FixedPoint:fixedPointTool:labelAllresults'),...
    DAStudio.message('FixedPoint:fixedPointTool:labelLoggedsignaldataresults'),...
    DAStudio.message('FixedPoint:fixedPointTool:labelMinMaxresults'),... 
    DAStudio.message('FixedPoint:fixedPointTool:labelOverflows'),...
    DAStudio.message('FixedPoint:fixedPointTool:labelConflictswithproposeddatatypes'),...
    DAStudio.message('FixedPoint:fixedPointTool:labelGroupsthatmustsharethesamedatatype')...
                   });
searchListener = handle.listener(searchComboBox,'SelectionChangedEvent',...
                                 @(s,e) localfilterresults(h,searchComboBox,s,e));
searchListener(2) = handle.listener(h,'UpdateFilterListEvent',...
                                 @(s,e) localfilterresults(h,searchComboBox,s,e));
if isempty(h.listeners)
    h.listeners = searchListener;
else
    h.listeners(end+1) = searchListener(1);
    h.listeners(end+1) = searchListener(2);
end
tb.addWidget(searchComboBox);

%-------------------------------------------------------
function localfilterresults(h,sel,s,e) %#ok
if isa(e.Source,'DAStudio.ToolBarComboBox') || isa(e.Source,'fxptui.explorer')
    res = h.getdataset.getresults;
    hasDTGrp = false; 
    if ~isempty(res)
        switch sel.getCurrentItem
          case 0 % ALL SIGNALS
            for i = 1:length(res)
                SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
            end
            h.hidePropsInListView({'DTGroup'});
          case 1 % ALL LOGGED SIGNALS
            for i = 1:length(res)
                if ~isempty(res(i).Signal)
                    SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
                else
                    res(i).isVisible = false;
                end
            end
            h.hidePropsInListView({'DTGroup'});
          case 2 % ALL Min/Max data
            for i = 1:length(res)
                if ~isempty(res(i).SimMin) || ~isempty(res(i).DesignMin) || ~isempty(res(i).DesignMax)
                    SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
                else
                    res(i).isVisible = false;
                end
            end
            h.hidePropsInListView({'DTGroup'});
          case 3 % All results that have overflows
            for i = 1:length(res)
                if ~isempty(res(i).OvfSat) || ~isempty(res(i).OvfWrap)
                    SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
                else
                    res(i).isVisible = false;
                end
            end
            h.hidePropsInListView({'DTGroup'});
          case 4 % All results that require attention
            for i = 1:length(res)
                if strcmp(res(i).Alert,'red') || strcmp(res(i).Alert,'yellow')
                    SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
                else
                    res(i).isVisible = false;
                end
            end
            h.hidePropsInListView({'DTGroup'});
          case 5 % Results that share the same DT
            for i = 1:length(res)
                if ~isempty(res(i).DTGroup)
                    SimulinkFixedPoint.Autoscaler.setResultVisible(res(i));
                    hasDTGrp = true;
                else
                    res(i).isVisible = false;
                end
            end
            if hasDTGrp
                h.showPropsInListView({'DTGroup'});
            end
          otherwise
        end
        % Fire a hierarchy change event to refresh the List View.
        node = h.getRoot;
        node.firehierarchychanged;
        if hasDTGrp
         h.imme.enableListSorting(true,'DTGroup',true);
        end
     end
end
% [EOF]

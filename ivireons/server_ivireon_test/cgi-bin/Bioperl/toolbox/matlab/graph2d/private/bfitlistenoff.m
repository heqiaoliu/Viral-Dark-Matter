function bfitlistenoff(fig)
% BFITLISTENOFF Disable listeners for Basic Fitting GUI. 

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.7.4.4 $  $Date: 2009/01/29 17:16:42 $

if ~isempty(bfitFindProp(fig, 'bfit_FigureListeners'))
    listeners = get(handle(fig), 'bfit_FigureListeners');
    bfitSetListenerEnabled(listeners.childadd, false);
    bfitSetListenerEnabled(listeners.childremove, false);
    bfitSetListenerEnabled(listeners.figdelete, false);
end

axesList = datachildren(fig);
lineL = plotchild(axesList, 2, true);

for i = lineL'
    if ~isempty(bfitFindProp(i, 'bfit_CurveListeners'))
	listeners = get(handle(i), 'bfit_CurveListeners');
        bfitSetListenerEnabled(listeners.tagchanged,false);
    end
    if ~isempty(bfitFindProp(i, 'bfit_CurveDisplayNameListeners'))
	listeners = get(handle(i), 'bfit_CurveDisplayNameListeners');
        bfitSetListenerEnabled(listeners.displaynamechanged,false);
    end
end

axesL = findobj(fig, 'type', 'axes');
for i = axesL'
    if ~isempty(bfitFindProp(i, 'bfit_AxesListeners'))
        listeners = get(handle(i), 'bfit_AxesListeners');
        if isequal(get(i,'tag'),'legend')
            bfitSetListenerEnabled(listeners.userDataChanged,false);
        else
            bfitSetListenerEnabled(listeners.lineAdded, false);
            bfitSetListenerEnabled(listeners.lineRemoved, false);
        end
    end
end


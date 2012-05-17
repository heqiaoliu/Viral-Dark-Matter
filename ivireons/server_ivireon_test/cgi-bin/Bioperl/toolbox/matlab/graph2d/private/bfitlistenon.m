function bfitlistenon(fig)
% BFITLISTENON Enable listeners for Basic Fitting GUI. 

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.7.4.4 $  $Date: 2009/01/29 17:16:43 $

if ~isempty(bfitFindProp(fig, 'bfit_FigureListeners'))
    listeners = get(handle(fig), 'bfit_FigureListeners');
    bfitSetListenerEnabled(listeners.childadd, true);
    bfitSetListenerEnabled(listeners.childremove, true);
    bfitSetListenerEnabled(listeners.figdelete, true);
end

axesList = datachildren(fig);
lineL = plotchild(axesList, 2, true);

for i = lineL'
    if ~isempty(bfitFindProp(i, 'bfit_CurveListeners'))
	listeners = get(handle(i), 'bfit_CurveListeners');
        bfitSetListenerEnabled(listeners.tagchanged, true);
    end
    if ~isempty(bfitFindProp(i, 'bfit_CurveDisplayNameListeners'))
	listeners = get(handle(i), 'bfit_CurveDisplayNameListeners');
        bfitSetListenerEnabled(listeners.displaynamechanged, true);
    end
end

axesL = findobj(fig, 'type', 'axes');
for i = axesL'
    if ~isempty(bfitFindProp(i, 'bfit_AxesListeners'))
	listeners = get(handle(i), 'bfit_AxesListeners');
        if isequal(get(i,'tag'),'legend')
            bfitSetListenerEnabled(listeners.userDataChanged, true);
        else
            bfitSetListenerEnabled(listeners.lineAdded, true);
            bfitSetListenerEnabled(listeners.lineRemoved, true);
        end
    end
end


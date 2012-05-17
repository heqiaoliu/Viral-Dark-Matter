function List = getlist(h,key)
%GETLIST  Builds requested list.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $ $Date: 2009/02/06 14:16:34 $

switch key
    case 'ActiveContainers'
        % List of visible containers with editable constraints
        List = find(h.ContainerList,'-depth',0,'Visible','on');
        hasConstr = logical([]);
        for ct = length(List):-1:1
            hasConstr(ct) = ~isempty(plotconstr.findConstrOnAxis(List(ct).Axes.getaxes));
        end
        List = List(hasConstr,:);
    case 'Constraints'
        % List of active constraints in targeted container
        cList = plotconstr.findConstrOnAxis(h.Container.Axes.getaxes);
        List = cList(1).TextEditor;
        for ct=2:numel(cList)
            List(ct) = cList(ct).TextEditor;
        end
end

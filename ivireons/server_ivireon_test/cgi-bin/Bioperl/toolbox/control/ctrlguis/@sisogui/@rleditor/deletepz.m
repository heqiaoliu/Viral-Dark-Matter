function deletepz(Editor,varargin)
%DELETEPZ  Deletes pole or zero graphically.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.20.4.3 $  $Date: 2008/05/31 23:16:15 $
LoopData = Editor.LoopData;

PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Acquire pole/zero position 
CP = get(PlotAxes,'CurrentPoint');     % mouse position
Lims = get(PlotAxes,{'Xlim','Ylim'});  % axis extent
Xscale = Lims{1}(2)-Lims{1}(1);
Yscale = Lims{2}(2)-Lims{2}(1);

% Determine nearest match
hPZ = [get(Editor.EditedPZ,{'Zero'}) ; get(Editor.EditedPZ,{'Pole'})];
hPZ = cat(1,hPZ{:});
X = get(hPZ,{'Xdata'});  X = cat(1,X{:});
Y = get(hPZ,{'Ydata'});  Y = cat(1,Y{:});
[distmin,imin] = ...
    min(abs(((CP(1,1)-X)/Xscale).^2 + ((CP(1,2)-Y)/Yscale).^2));

if distmin < 0.03^2,
    SelectedGroup = get(getappdata(hPZ(imin), 'PZVIEW'), 'GroupData');
    C = SelectedGroup.Parent;
    Ts = C.Ts;
    isel = find(C.PZGroup == SelectedGroup);
    Description = C.PZGroup(isel).describe(Ts);
    
    try
        % Start transaction
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Delete %s',Description{1}),...
            'OperationStore','on','InverseOperationStore','on');

        % Delete selected group from list of compensator PZ groups
        deletePZ(C,SelectedGroup);

        % Register transaction
        EventMgr.record(T);

        % Notify peers of deletion
        LoopData.dataevent('all');

        % Notify status and history listeners
        Status = sprintf('Deleted %s',Description{2});
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);
    catch ME
        % deletion failed
        % Parse error message and remove leading "Error..."
        errmsg = ME.message;
        idx = findstr('Error',errmsg);
        if ~isempty(idx)
            [junk,errmsg] = strtok(errmsg(idx(end):end),sprintf('\n'));
        end
        % Pop up error dialog and abort apply
        errordlg(errmsg,sprintf('Delete Pole/Zero'))
        
        T.Transaction.commit; % commit transaction before deleting wrapper
        delete(T);
    end
end

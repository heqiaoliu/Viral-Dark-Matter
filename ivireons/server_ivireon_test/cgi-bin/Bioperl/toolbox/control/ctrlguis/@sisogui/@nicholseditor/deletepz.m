function deletepz(Editor,varargin)
%DELETEPZ  Deletes pole or zero graphically.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.11.4.3 $  $Date: 2008/05/31 23:16:11 $
LoopData = Editor.LoopData;

% Data and handles
PZViews = Editor.EditedPZ;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Acquire current mouse position 
CP = get(PlotAxes, 'CurrentPoint');
Xm = CP(1,1);
Ym = CP(1,2);

% Get positions of compensator poles and zeros
hPZ = [get(PZViews, {'Zero'}) ; get(PZViews, {'Pole'})];
hPZ = cat(1, hPZ{:});
X = get(hPZ, {'Xdata'});  X = cat(1, X{:});
Y = get(hPZ, {'Ydata'});  Y = cat(1, Y{:});

% Adjust for X and Y scales (distance measured in pixels, not data units)
Lims = get(PlotAxes, {'Xlim', 'Ylim'});
IsLogY = strcmpi(get(PlotAxes, 'YScale'), 'log');
if IsLogY
  Lims{2} = log2(Lims{2});   Ym = log2(Ym);
  ispos = (Y > 0);
  Y(ispos,:)  = log2(Y(ispos,:));   
  Y(~ispos,:) = -Inf;   
end

% Determine nearest match
[distmin, imin] = ...
    min(abs(((Xm-X) / diff(Lims{1})).^2 + ((Ym-Y) / diff(Lims{2})).^2));

if distmin < 0.03^2,
    % Identify selected group and get its description
    SelectedGroup = get(getappdata(hPZ(imin), 'PZVIEW'), 'GroupData');
    C = SelectedGroup.Parent;
    Ts = C.Ts;
    isel = find(C.PZGroup == SelectedGroup);
    Description = C.PZGroup(isel).describe(Ts);
    
    try
        % Start transaction
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Delete %s', Description{1}),...
            'OperationStore','on','InverseOperationStore','on');

        % Delete selected group from list of compensator PZ groups
        deletePZ(C,SelectedGroup);

        % Register transaction
        EventMgr.record(T);

        % Notify peers of deletion
        Editor.LoopData.dataevent('all');

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

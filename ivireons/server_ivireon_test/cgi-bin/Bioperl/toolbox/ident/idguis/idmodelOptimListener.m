function idmodelOptimListener(es,ed,sitbgui)
% listener (callback) for linear model's iterative estimation in GUI

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/11/09 20:15:36 $

%es
%ed.Info.ModelType
if ~idIsValidHandle(sitbgui) || any(strcmpi(ed.Info.ModelType,{'idnlarx','idnlhw'}))
    return
end

XID = get(sitbgui,'UserData');
if isfield(XID,'iter')
    XIDiter = XID.iter;
else
    return;
end

isIdproc = strcmpi(ed.Info.ModelType,'idgrey');

try
    if isIdproc
        f = XID.procest(1);
    elseif any(strcmpi(ed.Info.ModelType,{'idss','idpoly','idarx'}))
        f = XID.parest(1);
    else
        return;
    end
catch
    return
end

if ~idIsValidHandle(f) || ~strcmpi(get(f,'vis'),'on')
    return
end

if isIdproc
    %idproc
    LocalUpdateIdprocWidnow;
else
    % other linear models
    LocalUpdateLinParWidnow;
end
nrb = []; fitb = []; impb = []; 

%--------------------------------------------------------------------------
    function LocalUpdateLinParWidnow
        % Update iteration info in Linear Parametric Model Window
        
        nrb = XIDiter(4);
        fitb = XIDiter(5);
        impb = XIDiter(6);

        LocalUpdateWidgets;
    end
    
    %----------------------------------------------------------------------
    function LocalUpdateIdprocWidnow
        % Update iteration info in Linear Parametric Model Window

        nrb = XIDiter(13);
        fitb = XIDiter(15);
        impb = XIDiter(17);

        LocalUpdateWidgets;

    end

    %----------------------------------------------------------------------
    function LocalUpdateWidgets
        
        Info = ed.Info;
        if ~isempty(Info.OldCost)
            lossratiostr = num2str((Info.OldCost-Info.Cost)/Info.OldCost*100,3);
        else
            lossratiostr = '-';
        end
        
        set(nrb,'string',['Iteration ',int2str(Info.Iteration)]);
        set(fitb,'string',['Fit: ',num2str(Info.Cost,3)]);
        set(impb,'string',['Improvement ',lossratiostr,' %']);
        drawnow
    end
end
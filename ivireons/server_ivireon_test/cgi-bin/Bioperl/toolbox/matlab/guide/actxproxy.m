function activex = actxproxy(hObject)
% ACTXPROXY Support function for GUIDE. Create ActiveX controls in a GUI. 
  
% Copyright 2002-2006 The MathWorks, Inc.

activex=[];

hObject = handle(hObject);
if ishandle(hObject)
    set(hObject,'Visible','off');
    fig = get(hObject, 'Parent');
    filename = get(fig,'FileName');
    if isempty(filename)
        appdata = getappdata(fig,'GUIDEOptions');
        if ~isempty(appdata) && isfield(appdata,'lastSavedFile')
            filename = appdata.('lastSavedFile');
        end
    end
    [p,fname ,e]=fileparts(filename);

    if ~ispc
        message = sprintf('This GUI contains Windows specific controls that are not supported on this platform.');
        errordlg(message, fname, 'modal');    
        delete hObject;
        return;
    end
    
    if ishandle(hObject) && isappdata(hObject, 'Control')
        control = getappdata(hObject, 'Control');
        currentPosition = getpixelposition(hObject);
        % create activex control
        try
            data = guidata(fig);
            
            if isappdata(0, genvarname(['OpenGuiWhenRunning_', fname])) && ~isfield(data,'keepactivexposition')
                % This is coming from running a GUIDE GUI
                [activex, container] = actxcontrol(control.ProgID, getpixelposition(hObject), fig);
                set(container,'units',get(hObject,'units'));
            else
                % This is coming from loading a GUI in GUIDE
                activex = actxcontrol(control.ProgID, getpixelposition(hObject), fig);
            end
        catch me
            delete(hObject);
            errordlg(me.message, 'Error');    
            return;
        end
        
        control.Runtime = 1;
        control.Instance = activex;
        setappdata(hObject, 'Control', control);
        
        activex.addproperty('Peer');
        activex.Peer = hObject;
        
        %restore activex to its design time states
        if ~isempty(control.Serialize)
            try
                 load(activex, fullfile(p, control.Serialize))
                 %for some active control(e.g. calendar), it needs move
                 %twice for right display. 
                 activex.move(currentPosition+1,true); 
                 activex.move(currentPosition); 
            catch me
                message = sprintf('%s ''%s'' could not be restored to its previous state.\n\nMake sure file %s is in the same directory as your GUI.', me.message, control.Name, control.Serialize);
                errordlg(message, fname, 'modal');
            end
        end
        
        %register event listeners only in FIG/M-file mode
        options = getappdata(fig,'GUIDEOptions');
        if options.mfile 
            callbacks = control.Callbacks;
            command = {};
            for i=1:length(callbacks)
                command={command{:} callbacks{i} fname};
            end
            registerevent(activex, reshape(command, 2,i)');         
        end
    end
end


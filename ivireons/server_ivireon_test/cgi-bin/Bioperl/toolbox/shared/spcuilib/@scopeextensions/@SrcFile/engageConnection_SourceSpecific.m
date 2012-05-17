function engageConnection_SourceSpecific(this)
%ENABLESOURCE Called by Source::enable method when a source is enabled.
%   Overload for SrcFile.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2009/10/29 16:08:37 $

hDataHandler = getDataHandler(this, getExtInst(this.Application, 'Visuals'));

setupFileBrowseObj(this, hDataHandler);

this.ErrorStatus = hDataHandler.ErrorStatus;
this.ErrorMsg    = hDataHandler.ErrorMsg;
if strcmpi(this.ErrorStatus, 'success')
    if isempty(this.ScopeCLI)
        openFile(hDataHandler, this);
    else
        openFile(hDataHandler, this, this.ScopeCLI.ParsedArgs{:});
    end
    this.ErrorStatus = hDataHandler.ErrorStatus;
    this.ErrorMsg    = hDataHandler.ErrorMsg;
    
    if strcmpi(this.ErrorStatus, 'success')
        
        this.Data = hDataHandler.Data;
        
        installDataHandler(this, hDataHandler);
        
        hGUI = getGUI(this.Application);
        set(findchild(hGUI, 'Base/StatusBar/StdOpts/Rate'), 'Visible', 'on');
        
        this.LastConnectFileOpened = this.DataHandler.FileName;
    end
end

% -------------------------------------------------------------------------
function setupFileBrowseObj(this, hDataHandler)
% Setup the file-browser manager object

% Initialize for connecting to a multimedia file
if isempty(this.FileBrowse)
    fbObj = spcwidgets.LoadFile;
    fbObj.Title = 'Connect to File';
    fbObj.FilterSpec = hDataHandler.FilterSpec;
    this.FileBrowse = fbObj;
    
%     this.InitialDirListener = handle.listener(fbObj, ...
%     fbObj.findprop('InitialDir'), ...
%     'PropertyPostSet', @(hh,ee)local_UpdateLastConnectFileOpened(this));

    this.InitialDirListener =  event.proplistener(fbObj, ...
        fbObj.findprop('InitialDir'), ...
        'PostSet', @(hh,ee)local_UpdateLastConnectFileOpened(this));
end

local_UpdateInitialDir(this);

% -------------------------------------------------------------------------
function local_UpdateInitialDir(this)
% Keep initial dir variables sync'd
this.LastConnectFileOpened = ...
    this.findProp('LastConnectFileOpened').Value;

% -------------------------------------------------------------------------
function local_UpdateLastConnectFileOpened(this)
% Keep initial dir variables sync'd
this.LastConnectFileOpened = this.FileBrowse.InitialDir;
this.findProp('LastConnectFileOpened').Value =...
    this.FileBrowse.InitialDir;

% [EOF]

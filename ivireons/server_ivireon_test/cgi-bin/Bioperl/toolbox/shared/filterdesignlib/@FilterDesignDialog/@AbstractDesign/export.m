function export(this, hdlg, method, warnflag, warnstr)
%EXPORT   Export the current design
%   EXPORT(H, HDLG, METHOD, WARN, WARNSTR) Export the current design on
%   object H.  HDLG is the handle to the dialog (to check if it is applied)
%   METHOD is which export to use, WARN is a booling for whether we need to
%   warn or not and WARNSTR is the string to use when we warn.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/03/04 16:31:30 $

if warnflag == true && lclHasUnappliedChanges(this, hdlg)
    
    unappliedchanges = FilterDesignDialog.message('UnappliedChanges');
    
    question = sprintf(unappliedchanges, warnstr);
    
    yes = FilterDesignDialog.message('Yes');
    no = FilterDesignDialog.message('No');
    cancel = FilterDesignDialog.message('Cancel');
    choice = questdlg(question, getDialogTitle(this), ...
        yes, no, cancel, yes);
    
    switch choice
        case yes
            hdlg.apply;
        case cancel
            return;
    end
end

% Call the required method.
feval(method, this);

% -------------------------------------------------------------------------
function launchfvtool(this) %#ok

hfvt = get(this, 'FVTool');
if ~isempty(hfvt) && isa(hfvt, 'sigtools.fvtool')
    figure(hfvt);
    return
end

Hd = get(this, 'LastAppliedFilter');
if isempty(Hd)    
    % If there is no filter stored in "LastAppliedFilter", redesign.
    Hd = design(this);
end

normFlag = get(Hd.getfdesign, 'NormalizedFrequency');
if normFlag
    normFlag = 'on';
else
    normFlag = 'off';
end

hfvt = fvtool(Hd, 'NormalizedFrequency', normFlag);

% Create a listener on the 'DialogApplied' event to update FVTool.
setappdata(hfvt, 'DialogAppliedListener', ...
    handle.listener(this, 'DialogApplied', @(h, ed) refresh_fvtool(this, hfvt)));

set(this, 'FVTool', hfvt);

% -------------------------------------------------------------------------
function hdl(this) %#ok
hHdl = get(this, 'HDLObj');
hDlg = get(this, 'HDLDialog');
if isempty(hDlg)
    Hd = get(this, 'LastAppliedFilter');
    if isempty(Hd)
        
        % If there is no filter stored in "LastAppliedFilter", redesign.
        Hd = design(this);
    end
    [cando, msg] = ishdlable(Hd);
    if cando
        % Call the API function to create the dialog.
        hHdl = fdhdlcoderui.fdhdltooldlg(Hd);
        hHdl.setfiltername(this.VariableName);
        
        hDlg = DAStudio.Dialog(hHdl);
        set(this, 'HDLDialog', hDlg);
        set(this, 'HDLObj', hHdl);
    else
        error('filterdesignlib:filterbuilder:UnsupportedStructure', msg);
        return;
    end
elseif ~ishandle(hDlg)
    hDlg =  DAStudio.Dialog(hHdl);
    set(this, 'HDLDialog', hDlg);
end
l = handle.listener(this, 'DialogApplied', @(h, ed) refresh_hdldlg(this, hHdl, hDlg));
setappdata(hHdl, 'Listeners', l);

% -------------------------------------------------------------------------
function mcode(this) %#ok

% Get the target file from the user.
[file, path] = uiputfile('*.m', 'Generate MATLAB code', 'untitled.m');
if isequal(file, 0),
    return;
end

file = fullfile(path, file);
if isempty(strfind(file, '.')),
    file = [file '.m'];
end

% Build the mcode buffer.
mcodebuffer = getMCodeBuffer(this);

% Set up the options for the public writer.
opts.H1         = 'Returns a discrete-time filter object.';
opts.outputargs = 'Hd';

% Call the public writer.
genmcode(file, mcodebuffer, opts);

% Open the file in the editor.
edit(file);

% -------------------------------------------------------------------------
function block(this) %#ok

hdsp = get(this, 'DSPFWIZ');
if isempty(hdsp) || ~isa(hdsp, 'siggui.dspfwiz')
    
    Hd = get(this, 'LastAppliedFilter');

    if isempty(Hd)

        % If there is no filter stored in "LastAppliedFilter", redesign.
        Hd = design(this);
    end
    hdsp = siggui.dspfwiz(Hd);
    
    % Set the default BlockName to the variable name from the design
    % dialog.  This will only work the first time that the dialog is
    % launched.  If the variable name is changed on the design dialog after
    % this is brought up, the blockname will not be updated.
    set(hdsp, 'BlockName', this.VariableName);
    set(this, 'DSPFWIZ', hdsp);
else
    refresh_dspfwizdlg(this, hdsp);
end

% Bring up a dialog for the realizemdl object.
dialog(hdsp);

% Add listeners to 'DialogApplied' to update the realizemdl dialog and to
% 'Notification' so that we can throw up errors.
l = [ ...
    handle.listener(this, 'DialogApplied', @(h, ed) refresh_dspfwizdlg(this, hdsp)); ...
    handle.listener(hdsp, 'Notification', @notification_listener); ...
    ];
setappdata(hdsp.FigureHandle, 'Listeners', l);

% -------------------------------------------------------------------------
function notification_listener(hSrc, ed)

% Ignore warnings and status changes.  Just rethrow the error in a dialog.
if strcmpi(ed.NotificationType, 'ErrorOccurred')
    error(hSrc, 'Filter Builder', ed.Data.ErrorString); %#ok error method
end

% -------------------------------------------------------------------------
function refresh_dspfwizdlg(this, hdsp)

hdsp.Filter = design(this);

% -------------------------------------------------------------------------
function refresh_hdldlg(this, hhdl, hhdldlg)

hhdl.setfilter(design(this));
hhdl.setfiltername(this.VariableName);
if ~isempty(hhdldlg) && ishandle(hhdldlg)
    hhdldlg.refresh;
end

% -------------------------------------------------------------------------
function refresh_fvtool(this, hfvt)

Hd = get(this, 'LastAppliedFilter');
if ~isempty(Hd) && isprop(hfvt, 'NormalizedFrequency')
    normFlag = get(Hd.getfdesign, 'NormalizedFrequency');
    if normFlag
        normFlag = 'on';
    else
        normFlag = 'off';
    end
    hfvt.NormalizedFrequency = normFlag;
end
hfvt.Filters = design(this);


% -------------------------------------------------------------------------
function b = lclHasUnappliedChanges(this, hdlg)

% If there is no dialog, there are no unapplied changes.
if isempty(hdlg)
    b = false;
    return;
end

% If the dialog reports no changes, we're done.
b = hdlg.hasUnappliedChanges;
if b
    % Shut off warning if the GUI is in its default state
    fl = {'ActiveTab','OperatingMode','FixedPoint'};
    s1 = rmfield(get(this),fl);
    that = eval(class(this));
    s2 = rmfield(get(that),fl);
    fxpt1 = get(this.FixedPoint);
    fxpt2 = get(that.FixedPoint);
    if isequal(s1,s2) && isequal(fxpt1,fxpt2),
        b = false;
    end
    % This hook is necessary for the Peak/Notch class (until it is
    % broken down in two separate classes) because the response type can
    % have two default values, either "Peak" or "Notch".
    b = hasUnappliedChanges(this,b,s1,s2,fxpt1,fxpt2);
end

% [EOF]

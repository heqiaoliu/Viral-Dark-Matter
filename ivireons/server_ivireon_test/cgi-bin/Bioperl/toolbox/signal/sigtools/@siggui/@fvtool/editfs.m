function editfs(hFVT)
%EDITFS Edit the Sampling Frequencies of the filters

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2009/10/16 06:42:48 $ 

hdlg = getcomponent(hFVT, '-class', 'siggui.dfiltwfsdlg');

% If there is no parameter dialog, create one.
if isempty(hdlg),
    filtobj = get(hFVT, 'privFilters');
    
    hdlg = siggui.dfiltwfsdlg(filtobj);
    addcomponent(hFVT, hdlg);
    
    l = handle.listener(hFVT, hFVT.findprop('Filters'), 'PropertyPostSet', @lclfilter_listener);
    set(l, 'CallbackTarget', hdlg);
    sigsetappdata(hFVT.FigureHandle, 'fvtool', 'listeners', 'dfiltwfsdlg_listener', l);    
end

if ~isrendered(hdlg),
    render(hdlg);
    hdlg.centerdlgonfig(hFVT.FigureHandle);
end

warnState = true;
for idxFilt = 1:length(hdlg.Filters)
    df = getfdesign(hdlg.Filters(idxFilt).Filter);
    if ~isempty(df)
        if ~((strcmpi(df.Response, 'audio weighting') ||...
                strncmp(df.Response, 'Octave', 6)));                               
            warnState = false;
            break
        end
    else
        warnState = false;
        break
    end
end
if warnState
    hw = siggui.dontshowagaindlg;
    set(hw, ...
        'Name', 'Sampling Frequency', ...
        'Text', {['Changing the sampling frequency for audio weighting ',...
        'and/or octave filters to a different value from the one ',...
        'you used at design time results in filters that do not ',...
        'meet the specifications derived from the corresponding ',...
        'standard.']}, ...
        'PrefTag', 'FsSetAudioFilterWarning',...
        'Icon', 'warn',...
        'NoHelpButton', true);
    
    % The need2show method returns false if the user has checked the box
    % in the past.  If it returns true, render the dialog and make it
    % visible.
    if hw.need2show
        render(hw);
        set(hw, 'Visible','on');
        
        % Add a listener to the parent being deleted so that we can
        % destroy the dontshowagain dialog.
        addlistener(hFVT.FigureHandle, 'ObjectBeingDestroyed', ...
            @(hh, eventStruct)delete(hw));
    end
end

% If there is a parameter dialog, make it visible and bring it to the front.
set(hdlg, 'visible', 'on');

% set the tag property of the sampling frequency dialog
set(hdlg.FigureHandle, 'Tag', 'SamplingFrequencyDlg');
figure(hdlg.FigureHandle);

% ---------------------------------------------------------------
function lclfilter_listener(hdlg, eventData)

set(hdlg, 'Filters', get(eventData, 'NewValue'));

% [EOF]

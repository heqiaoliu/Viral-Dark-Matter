function specgramdemo(y,Fs)
%SPECGRAMDEMO Spectrogram Display.
%   SPECGRAMDEMO displays a spectrogram of the data contained in the
%   "mtlb.mat" file.
%
%   SPECGRAMDEMO(y,Fs) displays a spectrogram of signal y, assuming
%   a sample rate of Fs Hz.  If y is specified but Fs is not,
%   a sample rate of 1 Hz is assumed.
%
%   Context menus and context-sensitive help are enabled throughout
%   the GUI.  Explore the visualization options by right-clicking
%   on various GUI items including the spectrogram, the colorbar,
%   etc.  For example, the panner may be zoomed by dragging the
%   mouse on the left- and right-hand edges of the highlighted
%   zoom region.  Right-clicking the highlighted zoom area brings
%   up a menu for focusing in on the zoom region, and provides
%   a link to context help.
%
%   Example: Load a data file containing laughter from a crowd
%   load laughter; % Variables y and Fs are loaded into the workspace
%   specgramdemo(y,Fs);
%
%   See also SPECTROGRAM, SPTOOL, FDATOOL.

% Author: D. Orofino
% Copyright 1988-2010 The MathWorks, Inc.
% $Revision: 1.11.4.21 $ $Date: 2010/05/20 03:09:23 $

if nargin<1,
  default_file = 'mtlb.mat';
  fprintf('Loading demo file (%s).\n\n',default_file);
  s = load(default_file);
  y  = s.mtlb; % default dataset
  Fs = s.Fs;
elseif nargin<2,
  Fs=1;  % default sample rate
end

% Create and render UI Framework
hFrame = create_uiframework;

% Create body of the GUI (e.g., axes, images, etc)
create_graphics(hFrame.WidgetHandle, y, Fs);

% -------------- ---------------------------------------------------
% install_plugin ---------------------------------------------------
% Check if audioplayer is available and plugin if so
  function hToolbar = install_plugin(hFrame)
    hToolbar = [];
    audioplayer_enabled = IsAudioplayerAvailable;
    if audioplayer_enabled
      % Get audio UIMGR plugin
      [hMenu, hToolbar] = render_uimgraudiotoolbar;
      
      % Path to menu & toolbar plugins
      plan = {hToolbar, 'UIFrame/Toolbar';
        hMenu, 'UIFrame/Menus'};
      
      u=uimgr.uiinstaller(plan);
      install(u,hFrame);
    end %if
    
  end % function

%----------------------------------------------------------
% render_playbutton
  function render_playbutton(hFrame)
    % Render play button to toolbar in case audio playback is not available
    htoolbarObj = hFrame.findchild('Toolbar');
    htoolbar = htoolbarObj.WidgetHandle;
    % Load toolbar icons
    icon_file = 'specgramdemoicons.mat';
    icon = load(icon_file);
    % Play icon
    uipushtool('parent',htoolbar, ...
      'tooltip','Play', ...
      'clickedcallback',@play_sound, ...
      'cdata',icon.playsound);
    % Reposition the playback buttons
    v = allchild(htoolbar);
    uistack(v(1), 'down', 5);
    
  end %function

%----------------------------------------------------------
% zoom_in
  function zoom_in(~,~,hfig)
    
    if nargin<3, hfig=gcbf; end
    
    ud = get(hfig,'userdata');
    
    % Get "pixel spacing" of image content
    im_xdata = get(ud.himage,'xdata');
    
    % We cannot zoom in if we only have a single xdata point.
    if length(im_xdata) < 2
      return;
    end
    im_dx    = im_xdata(2)-im_xdata(1);
    
    % Get current axis limit
    xlim     = get(ud.hax(1),'xlim');
    xlim_ctr = sum(xlim)/2;
    dxlim    = diff(xlim);
    
    % If current axis limits will only show 1 pixel width,
    % don't bother zooming in any further:
    if dxlim <= im_dx, return; end
    
    % Shrink limits 50% toward center of current limits:
    new_xlim = (xlim + xlim_ctr)/2;
    % Update the spectrogram and time slice axes:
    set(ud.hax(1),'xlim',new_xlim);  % [1 3]
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',new_xlim([1 2 2 1 1]));
    
    % update the audio selection to be played
    set_audio_selection(hfig, new_xlim * ud.Fs);
    
    % Update zoom signal, if enabled:
    % plot_signal_zoom(hfig);
    
  end %function

%----------------------------------------------------------
% zoom_out
  function zoom_out(~,~,hfig)
    
    % Zooming is relative to the current focus window
    % We will not zoom out beyond the current focus window
    
    if nargin<3, hfig=gcbf; end
    ud = get(hfig,'userdata');
    
    % Get current spectrogram axis limit (= thumbnail limits)
    thumb_xlim = get(ud.hax(1),'xlim'); % thumb limits = spectrogram limits
    thumb_dx = diff(thumb_xlim);
    
    % If spectrogram axis limits >= focus window limits,
    % don't bother zooming out any further:
    hax_time = ud.hax(2);
    focus_xlim = get(hax_time,'xlim');  % = panner xlim
    focus_dx = focus_xlim(2)-focus_xlim(1);
    if thumb_dx >= focus_dx, return; end
    
    % Grow limits 50% away from center of current limits:
    new_xlim = thumb_xlim + [-thumb_dx thumb_dx]/2;
    if new_xlim(1)<focus_xlim(1), new_xlim(1)=focus_xlim(1); end
    if new_xlim(2)>focus_xlim(2), new_xlim(2)=focus_xlim(2); end
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',new_xlim([1 2 2 1 1]));
    
    % Sync the spectrogram and time slice axes to the thumbnail:
    set(ud.hax(1),'xlim',new_xlim); % [1 3]
    
    % update the audio selection to be played
    set_audio_selection(hfig, new_xlim * ud.Fs);
    
    % Update zoom signal, if enabled:
    % plot_signal_zoom(hfig);
    
  end %function

%----------------------------------------------------------
% zoom_full
  function zoom_full(hco,eventStruct,hfig)
    
    if nargin<3, hfig=gcbf; end
    ud = get(hfig,'userdata');
    
    focusTimeReset(hco, eventStruct, hfig);  % reset focus window to full extent
    
    % Get time range of full spectrogram
    im_xdata = get(ud.himage,'xdata');
    if length(im_xdata) == 1
      new_xlim = get(ud.hax(3), 'XLim');
    else
      % Update the spectrogram and time slice axes:
      new_xlim = [min(im_xdata) max(im_xdata)];
      set(ud.hax([1 3]),'xlim',new_xlim);
    end
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',new_xlim([1 2 2 1 1]));
    
    % update the audio selection to be played
    set_audio_selection(hfig, new_xlim * ud.Fs);
    
    % Update zoom signal, if enabled:
    % plot_signal_zoom(hfig);
    
  end %function

%----------------------------------------------------------
% Parameter setting
  function param_setting(~,~)
    hfig = gcbf;
    ud = get(hfig, 'userdata');
    if isempty(ud.param_dlg)
      h = ud.param_dlgobj;
      h.NWindow = num2str(ud.Nwin);
      h.Nlap = num2str(ud.Nlap);
      h.Nfft = num2str(ud.Nfft);
      hdlg = DAStudio.Dialog(h);
      
      cls_listener = handle.listener(h, 'DialogClose',@dlg_close);
      set(cls_listener, 'CallbackTarget', hfig)
      ud.dlg_close = cls_listener;
      app_listener = handle.listener(h, 'DialogApply', @dlg_apply);
      set(app_listener, 'CallbackTarget', hfig)
      ud.dlg_apply = app_listener;
      
      ud.param_dlgobj = h;
      ud.param_dlg = hdlg;
      set(hfig, 'userdata', ud);
      
      % Pause for figure to finish the mouse click event
      % otherwise, the figure will recapture focus and hide the dialog
      pause(.05)
      hdlg.show;
      
    end %if
  end % function

%----------------------------------------------------------
% dialog close callback
  function dlg_close(hfig, eventdata)
    ud = get(hfig, 'userdata');
    ud.Nwin = str2double(ud.param_dlgobj.NWindow);
    ud.Nlap = str2double(ud.param_dlgobj.Nlap);
    ud.Nfft = str2double(ud.param_dlgobj.Nfft);
    ud.param_dlg = [];
    set(hfig, 'userdata', ud);
    update_gui(0, eventdata, hfig);
  end % function

%----------------------------------------------------------
% dialog apply callback
  function dlg_apply(hfig, eventdata)
    ud = get(hfig, 'userdata');
    ud.Nwin = str2double(ud.param_dlgobj.NWindow);
    ud.Nlap = str2double(ud.param_dlgobj.Nlap);
    ud.Nfft = str2double(ud.param_dlgobj.Nfft);
    set(hfig, 'userdata',ud);
    update_gui(0, eventdata, hfig);
  end % function

%---------------------------------------------------------------
  function left_plot_toggle
    % Define the newMode flag in ud.plot.left
    
    hfig = gcbf;
    ud = get(hfig,'userdata');
    
    if strcmp(ud.plot.left,'spectrogram_freq_slice'),
      newMode = 'signal_psd';
    else
      newMode = 'spectrogram_freq_slice';
    end
    ud.plot.left = newMode;
    set(hfig,'userdata',ud);
    
    % Update the left plot (Frequency slice and PSD)
    update_left_plot(hfig);
    
  end %function

%---------------------------------------------------------------
  function set_crosshairs(hfig,x,y)
    
    % Get current point in axis ASAP:
    %hfig   = gcbf;
    ud = get(hfig,'userdata');
    
    % Update cache
    ud.crosshair.xctr = x;
    if nargin == 3,
      ud.crosshair.yctr = y;
    else
      y = ud.crosshair.yctr;
    end
    set(hfig,'userdata',ud);
    
    % Update crosshairs
    set([ud.hspec_y ud.htime_y ud.htslice_y], 'xdata',[x x]);
    set([ud.hspec_x ud.hfreq_x], 'ydata',[y y]);
    
    % Update readouts
    update_time_readout(hfig);
    update_freq_readout(hfig);
    update_dB_readout(hfig);
    update_cmap_ptr(hfig);
    
    % For the VERTICAL and H/V crosshairs,
    % update the freq slice display:
    if strcmp(ud.plot.left,'spectrogram_freq_slice'),
      set(ud.hfreq_line,'xdata', get_spec_freq(hfig));
    end
    
    % For the HORIZONTAL and H/V crosshairs,
    % update the time slice display:
    if strcmp(ud.plot.top,'spectrogram_time_slice'),
      set(ud.htslice_line,'ydata', get_spec_tslice(hfig));
    end
    
  end %function

%---------------------------------------------------------------
  function center_cross(~,~)
    
    hfig = gcbf;
    ud = get(hfig,'userdata');
    
    % Determine center of spectrogram axis:
    xlim=get(ud.hax(1),'xlim');
    ylim=get(ud.hax(1),'ylim');
    
    set_crosshairs(hfig,mean(xlim),mean(ylim));
    update_cmap_ptr(hfig);
    
  end %function

%---------------------------------------------------------------
  function wbmotion_thumb(~,~)
    % thumbnail motion
    
    % Get current point in axis ASAP:
    hfig   = gcbf;
    ud     = get(hfig,'userdata');
    hax    = ud.hax(2);
    cp     = get(hax,'currentpoint');
    curr_x = cp(1,1);
    
    xmotion = curr_x - ud.thumb.origPt;
    width   = ud.thumb.width;
    xdata   = ud.thumb.xdata + xmotion;
    
    % Constrain to axis limits, so we don't lose cursor:
    xlim=get(hax,'xlim');
    min_xdata = min(xdata);
    max_xdata = max(xdata);
    if min_xdata < xlim(1),
      xdata=[xlim(1) xlim([1 1])+width xlim([1 1])];
    elseif max_xdata > xlim(2),
      xdata = [xlim(2)-width xlim([2 2]) xlim([2 2])-width];
    end
    
    % If the patch is larger than the zoom window
    if min(xdata)<=xlim(1) && max(xdata)>=xlim(2),
      % error(generatemsgid('InvalidRange'),'wbmotion_thumb: xdata is out of bounds');
      return
    end
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',xdata);
    
    % Scroll the spectrogram and time-slice axes:
    set(ud.hax(1),'xlim',xdata(1:2));  % [1 3]
    
    % update the audio selection to be played
    set_audio_selection(hfig, xdata(1:2) * ud.Fs);
    
    %if strcmp(ud.plot.top,'spectrogram_time_slice'),
    %   set(ud.htslice_line,'ydata', get_spec_tslice(hfig));
    %end
    
  end %function

%---------------------------------------------------------------
  function wbmotion_thumbleft(~,~)
    % thumbnail LEFT motion
    
    % Get current point in axis ASAP:
    hfig   = gcbf;
    ud     = get(hfig,'userdata');
    
    % current object may be either the patch, or the signal line
    hax    = ud.hax(2);
    cp     = get(hax,'currentpoint');
    curr_x = cp(1,1);
    
    xmotion = curr_x - ud.thumb.origPt;
    xdata   = ud.thumb.xdata;
    xdata([1 4 5]) = xdata([1 4 5]) + xmotion;
    
    % Constrain to axis limits, so we don't lose cursor:
    xlim = get(hax,'xlim');
    min_xdata = min(xdata);
    if min_xdata < xlim(1),
      xdata=[xlim(1) xdata([2 3])' xlim([1 1])];
    elseif min_xdata >= xdata(2),
      xdata = ud.thumb.xdata;
    end
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',xdata);
    
    % Scroll the spectrogram:
    set(ud.hax(1),'xlim',xdata(1:2));
    
    % update the audio selection to be played
    set_audio_selection(hfig, xdata(1:2) * ud.Fs);
    
  end %function

%---------------------------------------------------------------
  function wbmotion_thumbright(~,~)
    % thumbnail RIGHT motion
    
    % Get current point in axis ASAP:
    hfig   = gcbf;
    ud     = get(hfig,'userdata');
    
    hax    = ud.hax(2);
    cp     = get(hax,'currentpoint');
    curr_x = cp(1,1);
    
    xmotion = curr_x - ud.thumb.origPt;
    xdata   = ud.thumb.xdata;
    xdata([2 3]) = xdata([2 3]) + xmotion;
    
    % Constrain to axis limits, so we don't lose cursor:
    xlim = get(hax,'xlim');
    max_xdata = max(xdata);
    if max_xdata > xlim(2),
      xdata(2:3) = xlim(2);
    elseif max_xdata <= xdata(1),
      xdata = ud.thumb.xdata;
    end
    
    % Update the thumbnail:
    set(ud.hthumb,'xdata',xdata);
    
    % Scroll the spectrogram:
    set(ud.hax(1),'xlim',xdata(1:2));
    
    % update the audio selection to be played
    set_audio_selection(hfig, xdata(1:2) * ud.Fs);
    
  end %function

%---------------------------------------------------------------
  function wbup_thumb(~,~)
    
    % set spectrogram and time-slice xlims
    hfig = gcbf;
    ud = get(hfig,'userdata');
    
    % Commented out, due to flash:
    %     set(ud.hax([1 3]),'xlim',xlim);
    %
    % This is fine:
    %     set(ud.hax(1),'xlim',xlim);
    %
    % the following line causes flash in the spect image
    % this is the time-slice axis:
    % why does this affect the spectrogram axis? (overlap? clipping?)
    %     set(ud.hax(3),'xlim',xlim);
    
    changePtr(gcbf,'hand');
    install_cursorfcns(gcbf,'thumb');
    
    % Turn back on image axis visibility,
    % which was turned off during wbdown_thumb
    % so that it does not flash while panning:
    % Leave off!
    %set(ud.hax(1),'vis','on');
    %
    % Turn on crosshair visibility, which was shut off
    % during thumbnail panning (wbdown_thumb):
    set([ud.hspec_y ud.hspec_x ud.htslice_y],'vis','on');
    
  end %function

%---------------------------------------------------------------
  function wbup_thumbleft(~,~)
    % set spectrogram and time-slice xlims
    hfig = gcbf;
    ud = get(hfig,'userdata');
    xdata = get(ud.hthumb,'xdata');
    xlim = [min(xdata) max(xdata)];
    
    % Commented out, due to flash:
    %set(ud.hax([1 3]),'xlim',xlim);
    %
    % This is fine:
    set(ud.hax(1),'xlim',xlim);
    %
    % the following line causes flash in the spect image
    % this is the time-slice axis:
    %set(ud.hax(3),'xlim',xlim);
    
    changePtr(gcbf,'ldrag');
    install_cursorfcns(gcbf,'thumbleft');
    
    % Turn on crosshair visibility, which was shut off
    % during thumbnail panning (wbdown_thumb):
    set([ud.hspec_y ud.hspec_x],'vis','on');
    
  end %function

%---------------------------------------------------------------
  function wbup_thumbright(~,~)
    % set spectrogram and time-slice xlims
    hfig = gcbf;
    ud = get(hfig,'userdata');
    xdata = get(ud.hthumb,'xdata');
    xlim = [min(xdata) max(xdata)];
    
    % Commented out, due to flash:
    %set(ud.hax([1 3]),'xlim',xlim);
    %
    % This is fine:
    set(ud.hax(1),'xlim',xlim);
    %
    % the following line causes flash in the spect image
    % this is the time-slice axis:
    %set(ud.hax(3),'xlim',xlim);
    
    changePtr(gcbf,'rdrag');
    install_cursorfcns(gcbf,'thumbright');
    
    % Turn on crosshair visibility, which was shut off
    % during thumbnail panning (wbdown_thumb):
    set([ud.hspec_y ud.hspec_x],'vis','on');
    
  end %function

%---------------------------------------------------------------
  function update_status(hfig,str)
    % UPDATE_STATUS Update status text.
    
    ud = get(hfig,'userdata');
    hstatusbar = ud.huiframe.findchild('StatusBar');
    if(isa(hstatusbar, 'uimgr.uistatusbar'))
      % If str is not a string, skip
      % -1 is often used to "skip" the update
      if ischar(str),
        hstatusbar.WidgetHandle.Text = str;
      else
        strnwin = [ud.Nwintxt, num2str(ud.Nwin)];
        strnlap = [ud.Nlaptxt, num2str(ud.Nlap)];
        strnfft = [ud.Nffttxt, num2str(ud.Nfft)];
        hstatusbar.findchild('Nwin').WidgetHandle.Text = strnwin;
        hstatusbar.findchild('Nlap').WidgetHandle.Text = strnlap;
        hstatusbar.findchild('Nfft').WidgetHandle.Text = strnfft;
      end
    end
  end %function

%---------------------------------------------------------------
  function play_sound(~, ~)
    % PLAY_SOUND Play the selected sound segment
    
    hfig = gcbf;
    ud = get(hfig,'userdata');
    y = get(ud.htime_plot,'ydata');
    Fs = ud.Fs;
    
    xdata=get(ud.hthumb,'xdata');
    xlim=[min(xdata) max(xdata)];
    xidx=floor(xlim*Fs)+1;
    if xidx(1)<1, xidx(1)=1; end
    if xidx(2)>length(y), xidx(2)=length(y); end
    
    % Normalize sound and play:
    mx=max(abs(y));
    try
      wavplay(y(xidx(1):xidx(2))./mx,Fs,'sync');
    catch ME
      msg = ME.message;
      errordlg(msg,'Audio Playback Error','modal');
    end
    
  end %function

%---------------------------------------------------------------
% called by audioplayer during playback (if audioplayer enabled)
  function update_audio_position(hco, ~)
    if hco.isplaying,   % only do this if playback is in progress
      currentPosition = get(hco, 'CurrentSample') / get(hco, 'SampleRate');
      set_crosshairs(get(hco, 'UserData'), currentPosition);
    end
    
  end %function
%---------------------------------------------------------------
% utility to easily set playback boundaries
  function set_audio_selection(hfig, selectionPair)
    if ~ isempty(getappdata(hfig, 'audioSelection')), % only do this if audioplayer enabled
      selection.inPoint = selectionPair(1);
      if selection.inPoint < 1, selection.inPoint = 1; end
      selection.outPoint = selectionPair(2);
      setappdata(hfig, 'audioSelection', selection);
    end
    
  end %function

%---------------------------------------------------------------
% used to set the "put back position" of the vertical crosshair
  function start_function(hobj, ~)
    hfig = get(hobj, 'UserData');
    ud = get(hfig,'userdata');
    hpause = ud.huiframe.findchild('Toolbar','Playbuttons', 'Pause');
    hpause.WidgetHandle.Enable = 'on';
    hstop = ud.huiframe.findchild('Toolbar','Playbuttons', 'Stop');
    hstop.WidgetHandle.Enable = 'on';
    set(hobj, 'StopFcn', {@stop_function, ud.crosshair.xctr});
    
  end %function

%---------------------------------------------------------------
% when playback has completed, puts back the vertical crosshair
% to where it was when playback was initiated
  function stop_function(hobj, ~, where)
    while isplaying(hobj), pause(0); end  % let playback complete
    if get(hobj, 'CurrentSample') == 1, % if paused, don't put it back
      hfig = get(hobj, 'UserData');
      ud = get(hfig, 'userdata');
      hplay = ud.huiframe.findchild('Toolbar','Playbuttons', 'Play');
      hplay.WidgetHandle.State = 'off';
      hpause = ud.huiframe.findchild('Toolbar','Playbuttons', 'Pause');
      hpause.WidgetHandle.Enable = 'off';
      hstop = ud.huiframe.findchild('Toolbar','Playbuttons', 'Stop');
      hstop.WidgetHandle.Enable = 'off';
      set_crosshairs(get(hobj, 'UserData'), where);
    end
    
  end %function

%---------------------------------------------------------------
  function set_cmap_limits(hfig, new_dr)
    % Set new colormap limits
    
    ud = get(hfig,'userdata');
    hax_spec = ud.hax(1);
    hax_cbar = ud.hax(5);
    himage_cbar = ud.himage_cbar;
    
    % Set new dynamic range limits into spectrogram image
    set(hax_spec,'clim',new_dr);
    
    % colorbar is 1:256
    % actual spectrogram dynamic range is orig_dr
    % new spectrogram dynamic range is new_dr
    orig_dr = get(himage_cbar,'ydata');
    diff_dr = new_dr - orig_dr;
    cmapIndices_per_dB = 256./diff(orig_dr);  % a constant
    diff_clim = diff_dr .* cmapIndices_per_dB;
    cbar_clim = [1 256] + diff_clim;
    set(himage_cbar,'cdatamapping','scaled');  % do during creation
    set(hax_cbar,'clim',cbar_clim);
    
  end %function

%---------------------------------------------------------------
  function reset_cmap_limits(~,~)
    % Reset colormap limits to dynamic range of spectrogram data
    
    hfig = gcbf;
    ud = get(hfig,'userdata');
    orig_dr = get(ud.himage_cbar,'ydata');
    set_cmap_limits(hfig, orig_dr);
    
  end %function

%---------------------------------------------------------------
  function manual_cmap_limits(~,~,hfig)
    % manual_cmap_limits Manual change to colormap dynamic range limits
    
    if nargin<3,
      hfig = gcbf;
    end
    ud = get(hfig,'userdata');
    hax_spec = ud.hax(1);
    
    % Prompt for changes to cmap limits:
    clim = get(hax_spec,'clim');
    % 'dB value of first color in colormap:'
    % 'dB value of last color in colormap:'
    prompt={'Value of top color in colormap (dB):', ...
      'Value of bottom color in colormap (dB):'};
    def = {num2str(clim(2)), num2str(clim(1))};
    dlgTitle='Adjust dynamic range of colormap';
    lineNo=1;
    strs=inputdlg(prompt,dlgTitle,lineNo,def);
    if isempty(strs),
      return
    end
    new_dr = [str2double(strs{2}) str2double(strs{1})];
    
    set_cmap_limits(hfig,new_dr);
    
  end %function

%---------------------------------------------------------------
  function wbmotion_cmap(~,~)
    % WBMOTION_CMAP Graphical change to colormap dynamic range limits
    
    hfig = gcbf;
    ud = get(hfig,'userdata');
    hax_spec = ud.hax(1);
    hax_cbar = ud.hax(5);
    
    % Determine cursor starting and current points ASAP:
    cp    = get(hax_cbar,'CurrentPoint');
    newPt = cp(1,2);  % y-coord only
    dy    = newPt - ud.cbar.origPt;
    
    % if SelectionType was normal,
    %   update top or bottom of colorbar, only,
    %   depending on whether user started drag
    %   in the top or bottom of bar, respectively.
    % if SelectionType was extend,
    %   update both top AND bottom of bar simultaneously,
    %   translating colormap region.
    if strcmp(ud.cbar.SelectionType,'extend'),
      change_dr = [dy dy];
    else
      if ud.cbar.StartInTop,
        change_dr = [0 dy];
      else
        change_dr = [dy 0];
      end
    end
    new_dr = ud.cbar.starting_dr + change_dr;
    if diff(new_dr)<=0,
      new_dr = ud.cbar.starting_dr;
    end
    
    % Colorbar range is 1 to 256.
    % Actual spectrogram dynamic range is orig_dr
    % New spectrogram dynamic range is new_dr
    orig_dr = get(ud.himage_cbar,'ydata');    % a constant
    cmapIndices_per_dB = 256./diff(orig_dr);  % a constant
    diff_dr = new_dr - orig_dr;
    diff_clim = diff_dr .* cmapIndices_per_dB;
    cbar_clim = [1 256] + diff_clim;
    
    if diff(cbar_clim)>0,
      % Protect against poor choice of values
      set(hax_cbar,'clim',cbar_clim,'userdata',new_dr);
    end
    
    % We defer setting the new dynamic range limits
    % into the spectrogram image axis, as it will create
    % too much flash. Instead, on button-up, the new
    % limit is set.  See wbup_cmap() for details.
    
    % Set new dynamic range limits into spectrogram image
    % Note: userdata could be empty if this is the first entry...
    %set(ud.hax(1),'clim',new_dr);
    set(hax_spec,'clim',new_dr);
    
  end %function

%---------------------------------------------------------------
  function isChange = changePtr(hfig, newPtr)
    
    % Get current pointer name:
    ud = get(hfig,'userdata');
    
    % Is this a change in pointer type?
    isChange = ~strcmp(ud.currPtr,newPtr);
    if isChange,
      setptr(hfig, newPtr);
      ud.currPtr = newPtr;
      set(hfig,'userdata',ud);
    end
    
  end %function

%---------------------------------------------------------------
  function wbmotion_general(~,~,hfig)
    % General button motion
    %
    % Determines if cursor is over a crosshair
    % If so, changes pointer and installs crosshair buttondowns
    % If not, changes back to normal cursor and general buttondowns
    %   as necessary.
    
    if nargin<3,
      hfig = gcbf;
    end
    [isOverHV, isSegmentAxis, isCmapAxis,isTopHalfCmap, isThumb] = ...
      over_crosshair(hfig);
    
    if ~any(isOverHV),
      % Not hovering over a crosshair
      
      if isSegmentAxis,
        % Over an axis in which we can get a delta-time measurement
        if changePtr(hfig,'crosshair'),
          install_cursorfcns(hfig,'segment');
        end
        
      elseif isCmapAxis,
        % Over the colormap axes
        % Install the up/down pointer:
        if isTopHalfCmap,
          if changePtr(hfig,'udrag'),
            update_status(hfig,'Adjust upper dynamic range (shift to translate)');
            install_cursorfcns(hfig,'cmap');
          end
        else
          if changePtr(hfig,'ddrag'),
            update_status(hfig,'Adjust lower dynamic range (shift to translate)');
            install_cursorfcns(hfig,'cmap');
          end
        end
        
      elseif any(isThumb),
        % Over thumbnail - isThumb is a 3-element vector, [left center right],
        %  indicating whether cursor is over left edge, right edge, or is over
        %  the general thumbnail patch itself.
        
        % Install appropriate pointer:
        if isThumb(1),
          % Over left edge
          if changePtr(hfig,'ldrag'),
            install_cursorfcns(hfig,'thumbleft');
          end
        elseif isThumb(3),
          % Over right edge
          if changePtr(hfig,'rdrag'),
            install_cursorfcns(hfig,'thumbright');
          end
        else
          % Over general patch region
          if changePtr(hfig,'hand'),
            install_cursorfcns(hfig,'thumb');
          end
        end
        
      else
        % Not over a special axes:
        if changePtr(hfig,'arrow'),
          install_cursorfcns(hfig,'general');
        end
      end
      
    else
      % Pointer is over a crosshair (vert or horiz or both)
      if all(isOverHV),
        % Over both horiz and vert (near crosshair center):
        if changePtr(hfig,'fleur'),
          install_cursorfcns(hfig,'hvcross');
        end
      elseif isOverHV(1),
        % Over H crosshair
        if changePtr(hfig,'uddrag'),
          install_cursorfcns(hfig,'hcross');
        end
      else
        % Over V crosshair
        if changePtr(hfig,'lrdrag'),
          install_cursorfcns(hfig,'vcross');
        end
      end
    end
    
  end %function

%---------------------------------------------------------------
  function [y,isSegmentAxis,isCmapAxis,...
      isTopHalfCmap, isThumb] = over_crosshair(hfig)
    % Is the cursor hovering over the crosshairs?
    % There are two crosshairs, one an H-crosshair, the other
    % a V-crosshair.  The H and V crosshairs span several
    % different axes.
    %
    % Function returns a 2-element vector, indicating whether
    % the cursor is currently over the H- and/or V-crosshairs.
    %    y = [isOverH isOverV]
    
    y             = [0 0];
    isSegmentAxis = 0;
    isCmapAxis    = 0;
    isTopHalfCmap = 0;
    isThumb       = [0 0 0];  % left, middle, right regions
    
    % First, are we over any axes?
    hax = overAxes(hfig);
    if isempty(hax), return; end  % not over an axis
    
    % Get current point in axis:
    cp = get(hax,'currentpoint');
    ud = get(hfig,'userdata');
    
    % Axis which are "segmentable" have a vertical crosshair
    % e.g., spectrogram and time axes only
    isCmapAxis    = (hax==ud.hax(5));
    isSegmentAxis = (hax==ud.hax(1));
    
    % Determine if any horiz or vert crosshairs are
    % in this axis ... store as [anyHoriz anyVert]:
    hasHVCrossHairs = [any(hax==ud.hax([1 4])) ...
      any(hax==ud.hax(1:3))];
    
    % Is cursor in colormap axis?
    if (isCmapAxis),
      % is cursor in top half of colormap axis?
      orig_dr = get(ud.hax(1),'clim');
      isTopHalfCmap = (cp(1,2) >= sum(orig_dr)/2);
    end
    
    if any(hasHVCrossHairs),
      % Get cursor & crosshair positions:
      crosshair_pos = [ud.crosshair.xctr ud.crosshair.yctr];
      cursor_delta  = abs(crosshair_pos - cp(1,1:2));
      axis_dx       = diff(get(hax,'xlim'));
      axis_dy       = diff(get(hax,'ylim'));
      axis_delta    = [axis_dx axis_dy];
      
      % Is cursor within 1 percent of crosshair centers?
      % Limit test uses the reciprocal of the percentage tolerance
      %   1-percent -> 1 / 0.01 = 100
      % 1.5-percent -> 1 / 0.015 ~= 67
      %   2-percent -> 1 / 0.02 = 50
      %
      % Finally, allow a true result only if the axis
      % has a crosshair of the corresponding type
      %
      y = fliplr(cursor_delta * 67 < axis_delta) & hasHVCrossHairs;
    end
    
    % Are we over the thumbnail patch?
    % Check if we're over the time axis:
    if (hax == ud.hax(2)),
      % Get thumb patch limits:
      xdata=get(ud.hthumb,'xdata');
      xlim=[min(xdata) max(xdata)];
      
      % Is cursor over general patch area?
      thumb_delta = xlim - cp(1,1);
      isThumb(2) = thumb_delta(1)<=0 & thumb_delta(2)>=0;
      
      % Is cursor over left or right thumbnail edge?
      % Use same tolerance as crosshair test:
      axis_dx        = diff(get(hax,'xlim'));
      isThumb([1 3]) = (abs(thumb_delta) * 67 < axis_dx);
    end
    
  end %function

%---------------------------------------------------------------
  function h=overAxes(hfig)
    % overAxes Determine if pointer is currently over an
    % axis of the figure; the axis list comes from the
    % figure UserData (ud.hax).
    
    p = get(0,'PointerLocation');
    figPos = get(hfig,'Position');

    %the following 5 lines takes into account that uimgr added height of a
    %status bar at the bottom of the figure. So we need to factor that out
    %to make sure the pointer changing is done inside the axes correctly
    fig = get(hfig);
    ud = fig.UserData;
    hUIMgr = ud.huiframe;
    hStatusbar = hUIMgr.hStatusParent;
    statusbarHeight = get(hStatusbar, 'HeightLimits');

    if ~isempty(figPos),
      x  = (p(1)-figPos(1))/figPos(3);
      y  = (p(2)-figPos(2)- statusbarHeight(1) )/(figPos(4) - statusbarHeight(1));
      ud = get(hfig,'userdata');
      for h = ud.hax
        r = get(h,'Position');
        if ((x > r(1)) && (x < r(1)+r(3))) && ...
            ((y > r(2)) && (y < r(2)+r(4)))
          return;
        end
      end
    end
    h = [];
    %return
  end %function
%---------------------------------------------------------------
  function y=isLeftClick(hfig)
    
    % Keywords for key/button combinations:
    %         Left    Right
    %   none: normal  alt
    %  Shift: extend  alt
    %   Ctrl: alt     alt
    % Double: open    alt
    
    y=strcmp(get(hfig,'SelectionType'),'normal');
  end %function

%---------------------------------------------------------------
  function wbdown_hcross(~,~)
    % window button down in h-crosshair mode
    if ~isLeftClick(gcbf), return; end
    install_cursorfcns(gcbf,'hcross_buttondown');
    wbmotion_cross([],[],'h');
  end %function

%---------------------------------------------------------------
  function wbdown_vcross(~,~)
    % window button down in v-crosshair mode
    if ~isLeftClick(gcbf), return; end
    install_cursorfcns(gcbf,'vcross_buttondown');
    wbmotion_cross([],[],'v');
    
  end %function

%---------------------------------------------------------------
  function wbdown_hvcross(~,~)
    % window button down in hv-crosshair mode
    if ~isLeftClick(gcbf), return; end
    install_cursorfcns(gcbf,'hvcross_buttondown');
    wbmotion_cross([],[],'hv');
    
  end %function

%---------------------------------------------------------------
  function wbdown_segment(~,~)
    % window button down in segmentation mode
    if ~isLeftClick(gcbf), return; end
    install_cursorfcns(gcbf,'segment_buttondown');
    wbmotion_segment([],[],gcbf);
    
  end %function

%---------------------------------------------------------------
  function wbdown_thumb(~,~)
    % window button down in thumbnail mode
    if ~isLeftClick(gcbf), return; end
    
    % cache y-coord of pointer
    ud = get(gcbf,'userdata');
    hax_time = ud.hax(2);
    cp = get(hax_time,'currentpoint');
    xdata = get(ud.hthumb,'xdata');
    width = max(xdata)-min(xdata);
    
    ud.thumb.origPt = cp(1,1);   % x-coord only
    ud.thumb.width  = width;
    ud.thumb.xdata  = xdata;
    set(gcbf,'userdata',ud);
    
    changePtr(gcbf,'closedhand');
    install_cursorfcns(gcbf,'thumb_buttondown');
    
    
    % Turn off image axis visibility,
    % so that it does not flash while panning:
    %
    % off permanently now:
    %set(ud.hax(1),'vis','off');
    %
    % Turn off crosshair visibility:
    set([ud.hspec_y ud.hspec_x ud.htslice_y],'vis','off');
    
  end %function

%---------------------------------------------------------------
  function wbdown_thumbleft(~,~)
    
    % window button down in LEFT thumbnail mode
    if ~isLeftClick(gcbf), return; end
    
    % cache y-coord of pointer
    ud = get(gcbf,'userdata');
    hax_time = ud.hax(2);
    cp = get(hax_time,'currentpoint');
    xdata = get(ud.hthumb,'xdata');
    width = max(xdata)-min(xdata);
    
    ud.thumb.origPt = cp(1,1);   % x-coord only
    ud.thumb.width  = width;
    ud.thumb.xdata  = xdata;
    set(gcbf,'userdata',ud);
    
    install_cursorfcns(gcbf,'thumbleft_buttondown');
    
    % Turn off crosshair visibility:
    set([ud.hspec_y ud.hspec_x],'vis','off');
    
  end %function

%---------------------------------------------------------------
  function wbdown_thumbright(~,~)
    
    % window button down in LEFT thumbnail mode
    if ~isLeftClick(gcbf), return; end
    
    % cache y-coord of pointer
    ud = get(gcbf,'userdata');
    hax_time = ud.hax(2);
    cp = get(hax_time,'currentpoint');
    xdata = get(ud.hthumb,'xdata');
    width = max(xdata)-min(xdata);
    
    ud.thumb.origPt = cp(1,1);   % x-coord only
    ud.thumb.width  = width;
    ud.thumb.xdata  = xdata;
    set(gcbf,'userdata',ud);
    
    install_cursorfcns(gcbf,'thumbright_buttondown');
    
    % Turn off crosshair visibility:
    set([ud.hspec_y ud.hspec_x],'vis','off');
    
  end %function

%----------------------------------------------------
  function wbdown_cmap(~,~)
    % window button down in colormap mode
    
    hfig = gcbf;
    
    % Only allow left (normal) or shift+left (extend)
    st = get(hfig,'SelectionType');
    i=strmatch(st,{'normal','extend','open'});
    if isempty(i), return; end
    
    if i==3,
      % open dynamic range menu
      manual_cmap_limits([],[],hfig);
      return
    elseif i==2,
      % Shift+left button = translate,
      % show up/down cursor during drag
      % NOTE: cannot update cursor when shift is pressed
      %       but no mouse button is pressed (no event!)
      changePtr(hfig,'uddrag');
    end
    
    ud = get(hfig,'userdata');
    
    % cache y-coord of pointer
    hax_cbar = ud.hax(5);
    cp = get(hax_cbar,'currentpoint');
    ud.cbar.origPt = cp(1,2);   % y-coord only
    ud.cbar.SelectionType = st; % normal or extend
    
    % The current clim is in the spectrogram image
    % We want to know the midpoint of this
    orig_dr = get(ud.hax(1),'clim');
    ud.cbar.midPt = sum(orig_dr)/2;
    
    % Determine if pointer went down in top or bottom
    % half of colorbar:
    ud.cbar.StartInTop = (ud.cbar.origPt >= ud.cbar.midPt);
    
    % Cache original dynamic range:
    hax_spec = ud.hax(1);
    ud.cbar.starting_dr = get(hax_spec,'clim');
    set(hfig,'userdata',ud);
    
    install_cursorfcns(hfig,'cmap_buttondown');
    
    % Set initial clim into userdata in case motion
    % callback not performed (motion updates userdata).
    % wbup_cmap reads the userdata
    %
    % Turn off visibility during drag to prevent flash
    set(hax_cbar, ...
      'userdata',ud.cbar.starting_dr, ...
      'vis','off');
  end %function

%---------------------------------------------------------------
  function wbup_hcross(~,~)
    % window button up in h-crosshair mode
    install_cursorfcns(gcbf,'hcross');
    update_cmap_ptr(gcbf);
  end %function

%---------------------------------------------------------------
  function wbup_vcross(~,~)
    % window button up in v-crosshair mode
    install_cursorfcns(gcbf,'vcross');
    update_cmap_ptr(gcbf);
  end %function

%---------------------------------------------------------------
  function wbup_hvcross(~,~)
    % window button up in hv-crosshair mode
    install_cursorfcns(gcbf,'hvcross');
    update_cmap_ptr(gcbf);
  end %function

%---------------------------------------------------------------
  function wbup_segment(~,~)
    % window button up in segmentation mode
    install_cursorfcns(gcbf,'segment');
  end %function

%---------------------------------------------------------------
  function wbup_cmap(~,~)
    % window button up in colormap mode
    install_cursorfcns(gcbf,'cmap');
    
    % Set new dynamic range limits into spectrogram image
    % Note: userdata could be empty if this is the first entry...
    ud = get(gcbf,'userdata');
    hax_cbar=ud.hax(5);
    set(ud.hax(1),'clim',get(hax_cbar,'userdata'));
    set(hax_cbar,'vis','on'); % re-enable axis vis
    
    % Set new status msg, since it doesn't update
    % in the install_cursorfcns fcn for cmap callbacks
    % Do this by calling the general mouse-motion fcn:
    wbmotion_general([],[]);
    
  end %function

%---------------------------------------------------------------
  function update_cmap_ptr(hfig)
    % Update colormap pointer:
    
    ud = get(hfig,'userdata');
    v = get_spec_val(hfig);  % value in dB
    dy_tri = ud.crosshair.cbar.dy_tri;
    set(ud.hcmap_arrow,'ydata', [v+dy_tri v-dy_tri v]);
    
  end %function

%---------------------------------------------------------------
  function [i,j] = get_adjusted_crosshair_idx(hfig)
    % Find image matrix coordinate pair (j,i) under crosshair.
    % Adjust crosshair for "half-pixel offset" implicit in image display
    
    ud=get(hfig,'userdata');
    xc=ud.crosshair.xctr;
    yc=ud.crosshair.yctr;
    himage=ud.himage;
    im=get(himage,'cdata');
    
    % Get image pixel size:
    xdata=get(himage,'xdata');
    if length(xdata)>1, dx = xdata(2)-xdata(1); else dx=0; end
    
    ydata=get(himage,'ydata');
    if length(ydata)>1, dy = ydata(2)-ydata(1); else dy=0; end
    
    % Remove half a pixel size from apparent cursor position:
    xc=xc-dx/2;
    yc=yc-dy/2;
    
    % Find pixel coordinate under the crosshair:
    i=find(xc>=xdata);
    if isempty(i), i=1;
    else i=i(end)+1;
    end
    j=find(yc>=ydata);
    if isempty(j), j=1;
    else j=j(end)+1;
    end
    sz=size(im);
    if i>sz(2), i=sz(2); end
    if j>sz(1), j=sz(1); end
    
  end %function

%---------------------------------------------------------------
  function v = get_spec_val(hfig)
    
    ud    = get(hfig,'userdata');
    im    = get(ud.himage,'cdata');
    [i,j] = get_adjusted_crosshair_idx(hfig);
    v     = double(im(j,i));  % Get pixel value in double-precision
    
  end %function

%---------------------------------------------------------------
  function v = get_spec_freq(hfig)
    
    ud    = get(hfig,'userdata');
    im    = get(ud.himage,'cdata');
    [i,~] = get_adjusted_crosshair_idx(hfig);
    v     = im(:,i);  % Get pixel row in uint8
    
  end %function

%---------------------------------------------------------------
  function v = get_spec_tslice(hfig)
    
    ud    = get(hfig,'userdata');
    im    = get(ud.himage,'cdata');
    [~,j] = get_adjusted_crosshair_idx(hfig);
    v     = im(j,:);  % Get pixel column
    
  end %function

%---------------------------------------------------------------
  function update_time_readout(hfig,diffTime)
    
    ud = get(hfig,'userdata');
    if nargin<2,
      t=ud.crosshair.xctr;
      prefix='';
    else
      t=diffTime - ud.crosshair.xctr;
      prefix='\Deltat ';
    end
    
    % Update time readout
    [y,~,u] = engunits(t, 'latex','time');
    %str=[prefix num2str(y) ' ' u];
    str=[prefix sprintf('%.4f',y) ' ' u];
    set(ud.htext_time,'string',str);
    
  end %function

%---------------------------------------------------------------
  function update_freq_readout(hfig,diffFreq)
    
    ud=get(hfig,'userdata');
    if nargin<2,
      f=ud.crosshair.yctr;
      prefix='';
    else
      f=diffFreq - ud.crosshair.yctr;
      prefix='\Deltaf ';
    end
    
    % Update freq readout
    [y,~,u] = engunits(f,'latex');
    %str=[prefix num2str(y) ' ' u 'Hz'];
    str=[prefix sprintf('%.4f',y) ' ' u 'Hz'];
    set(ud.htext_freq,'string',str);
    
  end %function

%---------------------------------------------------------------
  function update_dB_readout(hfig,diffAmpl)
    
    ud = get(hfig,'userdata');
    if nargin<2,
      a=get_spec_val(hfig);
      prefix='';
    else
      a=diffAmpl - get_spec_val(hfig);
      prefix='\Deltaa=';
    end
    
    % Update mag readout
    %str=[prefix num2str(a) ' dB'];
    str=[prefix sprintf('%.4f',a) ' dB'];
    set(ud.htext_mag,'string',str);
    
  end %function

%---------------------------------------------------------------
  function clear_dB_readout(hfig)
    
    ud = get(hfig,'userdata');
    set(ud.htext_mag,'string','');
    
  end %function

%---------------------------------------------------------------
  function wbmotion_cross(~,~,sel)
    % motion callback during horiz/vert-crosshair selection
    % sel='h', 'v', or 'hv'
    
    % Get current point in axis ASAP:
    hfig = gcbf;
    hco  = gco;
    switch get(hco,'type')
      case 'axes'
        hax=hco;
      otherwise
        hax=get(hco,'parent');
    end
    
    cp   = get(hax,'currentpoint');
    ud   = get(hfig,'userdata');
    x    = cp(1,1);
    y    = cp(1,2);
    
    switch sel
      case 'h'
        x=ud.crosshair.xctr;
      case 'v'
        y=ud.crosshair.yctr;
    end
    
    % Constrain to axis limits, so we don't lose cursor:
    if any(sel=='v'),
      xlim=get(hax,'xlim');
      if x<xlim(1),
        x=xlim(1);
      elseif x>xlim(2),
        x=xlim(2);
      end
    end
    
    if any(sel=='h'),
      ylim=get(hax,'ylim');
      if y<ylim(1),
        y=ylim(1);
      elseif y>ylim(2),
        y=ylim(2);
      end
    end
    set_crosshairs(hfig,x,y);
    
  end %function

%---------------------------------------------------------------
  function wbmotion_segment(~,~,hfig)
    % motion callback during segmentation selection
    
    % Get current point in axis ASAP:
    if nargin<3,
      hfig = gcbf;
    end
    
    hax=gco;
    t=get(hax,'type');
    if ~strcmp(t,'axes'),
      hax = get(hax,'parent');
    end
    cp   = get(hax,'currentpoint');
    x    = cp(1,1);
    y    = cp(1,2);
    
    % Constrain to axis limits, so we don't lose cursor:
    xlim=get(hax,'xlim');
    if x<xlim(1),
      x=xlim(1);
    elseif x>xlim(2),
      x=xlim(2);
    end
    ylim=get(hax,'ylim');
    if y<ylim(1),
      y=ylim(1);
    elseif y>ylim(2),
      y=ylim(2);
    end
    
    update_time_readout(hfig,x);
    update_freq_readout(hfig,y);
    clear_dB_readout(hfig);
    
  end %function

%---------------------------------------------------------------
  function install_cursorfcns(hfig,cursorType)
    
    switch lower(cursorType)
      case 'none'
        dn     = [];
        motion = [];
        up     = [];
        status = '';
        
      case 'general'
        dn     = [];
        motion = @wbmotion_general;
        up     = [];
        status = 'Ready';
        
      case 'segment'
        dn     = @wbdown_segment;
        motion = @wbmotion_general;
        up     = [];
        status = 'Ready';
        
      case 'segment_buttondown'
        dn     = [];
        motion = @wbmotion_segment;
        up     = @wbup_segment;
        status = 'Difference from crosshair';
        
      case 'thumb'
        % button not pushed, thumbnail highlighted
        dn     = @wbdown_thumb;
        motion = @wbmotion_general;
        up     = [];
        status = 'Pan zoom window';
        
      case 'thumb_buttondown'
        % button pushed, thumbnail highlighted
        dn     = [];
        motion = @wbmotion_thumb;
        up     = @wbup_thumb;
        status = 'Release to set zoom window';
        
      case 'thumbleft'
        % button not pushed, left thumbnail edge highlighted
        dn     = @wbdown_thumbleft;
        motion = @wbmotion_general;
        up     = [];
        status = 'Adjust zoom window left edge';
        
      case 'thumbleft_buttondown'
        % button pushed, thumbnail highlighted
        dn     = [];
        motion = @wbmotion_thumbleft;
        up     = @wbup_thumbleft;
        status = 'Release to set zoom window';
        
      case 'thumbright'
        % button not pushed, right thumbnail edge highlighted
        dn     = @wbdown_thumbright;
        motion = @wbmotion_general;
        up     = [];
        status = 'Adjust zoom window right edge';
        
      case 'thumbright_buttondown'
        % button pushed, right thumbnail edge highlighted
        dn     = [];
        motion = @wbmotion_thumbright;
        up     = @wbup_thumbright;
        status = 'Release to set zoom window';
        
      case 'hcross'
        % button not pushed, h-crosshair highlighted
        dn     = @wbdown_hcross;
        motion = @wbmotion_general;
        up     = [];
        status = 'Move horizontal cursor';
        
      case 'hcross_buttondown'
        % button pushed while over horiz cross-hair
        dn     = [];
        motion = {@wbmotion_cross,'h'};
        up     = @wbup_hcross;
        status = 'Release to update cursor';
        
      case 'vcross'
        dn     = @wbdown_vcross;
        motion = @wbmotion_general;
        up     = [];
        status = 'Move vertical cursor';
        
      case 'vcross_buttondown'
        dn     = [];
        motion = {@wbmotion_cross,'v'};
        up     = @wbup_vcross;
        status = 'Release to update cursor';
        
      case 'hvcross'
        dn     = @wbdown_hvcross;
        motion = @wbmotion_general;
        up     = [];
        status = 'Move crosshair cursor';
        
      case 'hvcross_buttondown'
        dn     = [];
        motion = {@wbmotion_cross,'hv'};
        up     = @wbup_hvcross;
        status = 'Release to update cursor';
        
        % Change dynamic range of colormap
      case 'cmap'
        dn     = @wbdown_cmap;
        motion = @wbmotion_general;
        up     = [];
        % Status is set in wbmotion_general function
        % since it depends on which pointer we're using
        status = -1;
        
      case 'cmap_buttondown'
        dn     = [];
        motion = @wbmotion_cmap;
        up     = @wbup_cmap;
        status = 'Release to update colormap';
        
      otherwise
        error(generatemsgid('InvalidParam'),'Unrecognized cursorfcn');
    end
    
    set(hfig, ...
      'windowbuttondownfcn',  dn, ...
      'windowbuttonmotionfcn',motion, ...
      'windowbuttonupfcn',    up)
    
    update_status(hfig,status);
    
  end %function

%---------------------------------------------------------------
  function resize_fig(~,~)
    % Callback to resize the figure
    
    update_axes_with_eng_units(gcbf);
    
  end %function

%---------------------------------------------------------------
  function update_axes_with_eng_units(hfig)
    
    % Update the tick marks for axes that are using engineering units
    % For example, a resize could have added or removed ticks, and the
    % axes would no longer have the proper tick marks
    ud     = get(hfig,'userdata');
    hFrame = getappdata(hfig, 'UIMgr');
    if strcmp(hFrame.Enable, 'on')
      hax_time = ud.hax(2);
      hax_freq = ud.hax(4);
      
      % Update freq-axis labels for engineering units, etc:
      yy=get(hax_freq,'ytick');
      [cs,eu] = convert2engstrs(yy);
      set(hax_freq,'yticklabel',cs);
      set(get(hax_freq,'ylabel'),'string',['Frequency, ' eu 'Hz']);
      
      % Update time-axis labels for engineering units, etc:
      yy=get(hax_time,'xtick');
      [cs,eu] = convert2engstrs(yy,'time');
      set(hax_time,'xticklabel',cs);
      set(get(hax_time,'xlabel'),'string',['Time, ' eu]);
    end
    
  end %function

%---------------------------------------------------------------
  function update_gui(~, ~, hfig)
    
    if nargin<3, hfig=gcbf; end
    
    ptr.ptr = get(hfig,'pointer');
    ptr.shape = get(hfig,'pointershapecdata');
    ptr.hot = get(hfig,'pointershapehotspot');
    setptr(hfig,'watch');  % set user's expectations...
    
    ud = get(hfig,'userdata');
    hax_spec     = ud.hax(1);
    hax_time     = ud.hax(2);
    hax_tslice   = ud.hax(3);
    hax_freq     = ud.hax(4);
    hax_cbar     = ud.hax(5);
    hax_cbar_ind = ud.hax(6);
    
    % Get spectrogram parameters:
    Nwin = ud.Nwin;
    Nlap = ud.Nlap;
    Nfft = ud.Nfft;
    % Recompute spectrogram
    y      = ud.y;
    Fs     = ud.Fs;
    window = 'blackman';
    w = feval(window,Nwin,'periodic');
    try
      [b,f,t]=spectrogram(y,w,Nlap,Nfft,Fs);
      [Pxx, W] = pwelch(y,w,Nlap,Nfft,Fs);
      % Reset Nwin/Nlap/Nfft:
      ud.Nwinbak = Nwin;
      ud.Nlapbak = Nlap;
      ud.Nfftbak = Nfft;
      set(hfig, 'userdata', ud);
      update_status(hfig, -1);
    catch ME
      % Error occurred
      % Put up modal error display, then
      % get spectrogram params from cache (userdata)
      msg = ME.message;
      errordlg(msg,'Specgram Demo Error','modal');
      
      % Reset Nwin/Nlap/Nfft:
      ud.Nwin = ud.Nwinbak;
      ud.Nlap = ud.Nlapbak;
      ud.Nfft = ud.Nfftbak;
      return
    end
    
    ud.f = f;
    ud.t = t;
    
    % Pxx is the distribution of power per unit frequency.
    ud.Pxx = Pxx;
    
    % W is the vector of normalized frequencies at which the PSD is estimated.
    ud.w = W;
    
    % Carefully execute log10:
    wstate=warning;
    warning off; %#ok
    b = 20*log10(abs(b));
    warning(wstate);
    
    % Handle -inf's:
    i_inf = find(isinf(b(:)));
    if ~isempty(i_inf),
      % Set all -inf points to next-lowest value:
      b(i_inf)=inf;
      min_val=min(b(:));
      b(i_inf)=min_val;
    end
    
    blim = [min(b(:)) max(b(:))];
    spec_xlim = [0 max(t)];
    spec_ylim = [0 max(f)];
    
    % Update spectrogram
    set(ud.himage,'cdata',b, 'xdata',t, 'ydata',f);
    set(hax_spec,'xlim',spec_xlim, 'ylim', spec_ylim);
    
    % Update colorbar
    set(ud.himage_cbar, 'ydata',blim, 'cdata', (1:256)');
    set(hax_cbar,'ylim',blim);
    set(hax_cbar_ind, 'ylim',blim);
    
    % Update time slice
    rows=size(b,1);
    bi=floor(rows/2); if bi<1, bi=1; end
    set(ud.htslice_line,'xdata',t, 'ydata',b(bi,:));
    set(hax_tslice, 'xlim',spec_xlim, 'ylim',blim);
    % Use 2 ticks only
    new_ticks = return2ticks(hax_tslice);
    set(hax_tslice,'Ytick',new_ticks);
    
    % frequency slice
    cols=size(b,2);
    bj=floor(cols/2); if bj<1, bj=1; end
    set(ud.hfreq_line, 'xdata',b(:,bj),'ydata',f);
    set(hax_freq, 'ylim',spec_ylim,'xlim',blim);
    
    % Use 2 ticks only
    new_xticks = return2ticks(ud.hax(4));
    set(ud.hax(4),'Xtick',new_xticks);
    
    
    % full time trace
    % this creates the signal trace that goes on the pannable time plot 
    % below the main plot
    half_nfft = ceil(Nfft/2);
    t1=(0 : length(y)-half_nfft)/Fs;
    set(ud.htime_plot,'xdata',t1,'ydata',y(half_nfft:end));
    set(hax_time, 'xlim',spec_xlim);
    
    update_axes_with_eng_units(hfig);
    
    % setup thumbnail patch
    axylim = get(hax_time,'ylim');
    ymax = axylim(2);
    ymin = axylim(1);
    tmax = max(t);
    tmin = min(t);
    set(ud.hthumb, ...
      'xdata',[tmin tmax tmax tmin tmin], ...
      'ydata',[ymin ymin ymax ymax ymin]);
    
    % Reset crosshair positions
    crosshair      = ud.crosshair;
    crosshair.xctr = mean(spec_xlim);
    crosshair.yctr = mean(spec_ylim);
    time_ylim      = get(hax_time,'ylim');
    freq_xlim      = get(hax_freq,'xlim');
    tslice_ylim    = get(hax_tslice,'ylim');
    
    % Crosshairs:
    set(ud.hspec_x, ...
      'xdata',spec_xlim, ...
      'ydata',[crosshair.yctr crosshair.yctr]);
    set(ud.hspec_y, ...
      'xdata',[crosshair.xctr crosshair.xctr], ...
      'ydata',spec_ylim);
    set(ud.htime_y, ...
      'xdata',[crosshair.xctr crosshair.xctr], ...
      'ydata',time_ylim);
    set(ud.htslice_y, ...
      'xdata',[crosshair.xctr crosshair.xctr], ...
      'ydata',tslice_ylim);
    set(ud.hfreq_x, ...
      'xdata',freq_xlim, ...
      'ydata',[crosshair.yctr crosshair.yctr]);
    
    % Colormap indicator triangle:
    dy_tri=.025*diff(blim);
    yp=b(bi,bj);
    ytri=[yp+dy_tri yp-dy_tri yp ];
    set(ud.hcmap_arrow, ...
      'erase','xor', ...
      'linestyle','none', ...
      'xdata',[0 0 1], ...
      'ydata',ytri);
    crosshair.cbar.dy_tri = dy_tri;
    
    % Update user data:
    ud.crosshair = crosshair;
    set(hfig,'userdata',ud);
    
    % Text readouts:
    update_time_readout(hfig);
    update_freq_readout(hfig);
    update_dB_readout(hfig);
    
    %str=[num2str(b(bi,bj)) ' dB'];
    %set(ud.htext_mag,'string',str);
    
    % Re-establish pointer cursor, etc:
    set(hfig,'pointer',ptr.ptr, ...
      'pointershapecdata',ptr.shape, ...
      'pointershapehotspot',ptr.hot);
    
    %Set to normal display
    zoom_full(0, 0, hfig);
    
  end %function

%---------------------------------------------------------------
  function printdlg_cb(~,~)
    printdlg(gcbf);
  end %function

%---------------------------------------------------------------
  function printpreview_cb(~,~, ~)
    printpreview(gcbf);
  end %function

%---------------------------------------------------------------
  function close_cb(~,~)
    hfig = gcbf;
    ud = get(hfig, 'userdata');
    if ~isempty(ud.param_dlg)
      delete(ud.param_dlg);
      ud.param_dlg = [];
    end
    set(hfig, 'userdata', ud);
    delete(gcbf);
  end %function

%----------------------------------------------------------
% IsAudioplayerAvailable
  function audioplayer_enabled = IsAudioplayerAvailable
    audioplayer_enabled = true;
    try
      audioplayer(zeros(1024,1), 44100);  %make a player for the normalized signal
    catch %#ok
      audioplayer_enabled = false;
    end
    
  end

%---------------------------------------------------------------
  function create_graphics(hfig, y,Fs)
    %CREATE_GRAPHICS Render the graphics.
    
    hVisParent = hfig;
    if isappdata(hfig, 'UIMgr')
      hVisParent = get(getappdata(hfig, 'UIMgr'), 'hVisParent');
    end
    
    % Try to create audioplayer object for audio playback and tracking cursor
    player = audioplayer(y / abs(max(y)), Fs);  %make a player for the normalized signal
    set(player, 'UserData', hfig, 'TimerPeriod', 0.05, 'TimerFcn', @update_audio_position, ...
        'StartFcn', @start_function);
    % the toolbar callback fcns look for these named bits of appdata
    setappdata(hfig, 'theAudioPlayer', player);
    setappdata(hfig, 'theAudioRecorder', []);
    selection.inPoint = 1;
    selection.outPoint = length(y);
    setappdata(hfig, 'audioSelection', selection); % selection starts as "full"
    
    % specgram
    % inputs: t, f, b
    hax_spec = axes('parent',hVisParent, ...
      'pos',[.25 .275 .625 .525]);
    himage=image('parent',hax_spec);
    axis xy; colormap(jet)
    
    % workaround for xor erase mode problem on UNIX
    mode='normal';
    if ispc
      mode='xor';
    end
    
    set(himage,'erase',mode,'cdatamapping','scaled');
    set(hax_spec, ...
      'box','on', ...
      'draw','fast', ...
      'xticklabel','');
    
    % Shut off image axis visibility
    set(hax_spec, 'vis','off');
    
    % time slice
    hax_tslice = axes('parent',hVisParent,...
      'pos',[.25 .825 .625 .1]);
    htslice_line=line('parent',hax_tslice,...
      'color','b');
    set(htslice_line,'erase','xor');
    set(hax_tslice, ...
      'box','on', ...
      'fontsize',8, ...
      'draw','fast', ...
      'xticklabel','', ...
      'xtick',[],  ...
      'yaxisloc','right');
    ylabel('dB');
    sz=size(y);
    
    % Title of time slice plot
    [ey,~,eu]=engunits(Fs,'latex');
    str=['Data=[' num2str(sz(1)) 'x' num2str(sz(2)) '], Fs=' ...
      num2str(ey) ' ' eu 'Hz'];
    title(str);
    
    % colorbar
    cmapLen = 256;
    hax_cbar = axes('parent',hVisParent,...
      'pos',[.91 .275 .03 .525]);
    himage_cbar = image([0 1],[0 1],(1:cmapLen)');
    set(himage_cbar,'cdatamapping','scaled','erase','none');
    set(hax_cbar, ...
      'draw','fast', ...
      'fontsize',8, ...
      'box','on', ...
      'xticklabel','', ...
      'Ydir','normal', 'YAxisLocation','right', 'xtick',[]);
    
    % frequency slice
    hax_freq = axes('parent',hVisParent,...
      'pos',[.1 .275 .125 .525]);
    hfreq_line=line('parent',hax_freq,...
      'color','b');
    set(hfreq_line,'erase','xor');
    set(hax_freq, ...
      'fontsize',8, ...
      'box','on',...
      'draw','fast', ...
      'xdir','rev', ...
      'xaxisloc','top');
    ylabel('Frequency, Hz');
    xlabel('dB');
    
    % colorbar indicator
    hax_cbar_ind = axes('parent',hVisParent,...
      'pos',[.885+.01 .275 .015 .525]);
    set(hax_cbar_ind,'vis','off','xlim',[0 1],'ylim',[0 1], ...
      'draw','fast', ...
      'fontsize',8, ...
      'yaxisloc','right');
    
    % full time trace
    % inputs: y, Fs
    hax_time = axes('parent',hVisParent,...
      'pos',[.25 .15 .625 .1]);
    htime_plot = line('parent',hax_time,...
      'color','b');
    set(hax_time, ...
      'box','on',...
      'fontsize',8, ...
      'draw','fast', ...
      'yaxisloc','right');
    xlabel('parent',hax_time,...
      'Time, secs');
    ylabel('parent',hax_time,...
      'Ampl');
    
    % thumbnail patch
    %bgclr = get(0,'defaultuicontrolbackgr');
    %bgclr = get(0,'defaultfigurecolor');
    bgclr = 'b';
    hthumb = patch([0 0 1 1 0], [0 1 1 0 0], bgclr, ...
      'parent',hax_time,...
      'edgecolor','k', ...
      'erase','xor');
    
    % Crosshairs:
    hspec_x=line('parent',hax_spec, ...
      'erase','xor');
    hspec_y=line('parent',hax_spec, ...
      'erase','xor');
    htime_y=line('parent',hax_time, ...
      'linewidth',2, ...
      'erase','xor');
    htslice_y=line('parent',hax_tslice, ...
      'erase','xor');
    hfreq_x=line('parent',hax_freq, ...
      'erase','xor');
    
    % Colormap indicator triangle:
    hcmap_arrow=patch('parent',hax_cbar_ind, ...
      'xdata',[0 0 1], ...
      'ydata',[0 0 0]);
    
    % Text readouts:
    
    hax_readout = axes('parent',hVisParent,...
      'pos',[0.02 .09 .185 .15],'vis','off');
    patch([0 1 1 0 0],[0 0 1 1 0],'w');
    htext_time = text('parent',hax_readout, 'pos',[0.075 .8], ...
      'erase',mode);
    htext_freq = text('parent',hax_readout, 'pos',[0.075 .5], ...
      'erase',mode);
    htext_mag = text('parent',hax_readout, 'pos',[0.075 .2], ...
      'erase',mode);
    
    % Spectrogram controls:
    %
    % segment length
    ylen = length(y);
    Nfft = min(256,ylen);
    Nwin = Nfft;
    % Nlap = min(Nwin,ceil(Nwin/2));
    Nlap = min(Nwin,200);
    ud = get(hfig, 'userdata');
    ud.Nwin = Nwin;
    ud.Nfft = Nfft;
    ud.Nlap = Nlap;
    ud.Nwinbak = Nwin;
    ud.Nfftbak = Nfft;
    ud.Nlapbak = Nlap;
    
    %set(hfig,'colormap',jet(256));
    
    % Retain info in figure userdata:
    ud.hfig        = hfig;
    ud.hax         = [hax_spec hax_time hax_tslice hax_freq hax_cbar hax_cbar_ind];
    ud.hspec_x     = hspec_x;
    ud.hspec_y     = hspec_y;
    ud.htime_y     = htime_y;
    ud.htslice_y   = htslice_y;
    ud.hfreq_x     = hfreq_x;
    ud.hcmap_arrow = hcmap_arrow;
    ud.hfreq_line  = hfreq_line;
    ud.htslice_line  = htslice_line;
    ud.htime_plot  = htime_plot;
    ud.htext_time  = htext_time;
    ud.htext_freq  = htext_freq;
    ud.htext_mag   = htext_mag;
    ud.htext_status= [];%htext_status;
    ud.crosshair   = [];
    ud.himage      = himage;
    ud.himage_cbar = himage_cbar;
    ud.hthumb      = hthumb;
    ud.f=[];
    ud.t=[];
    ud.y=y;
    ud.Fs=Fs;
    ud.currPtr = '';  % current pointer
    ud.Pxx = [];
    ud.w = [];
    ud.param_dlg = [];
    
    % Set plot default modes:
    ud.plot.top  = 'spectrogram_time_slice';
    ud.plot.left = 'spectrogram_freq_slice';
    
    set(hfig,'userdata',ud);
    
    % Protect GUI from user plots, etc:
    set([hfig ud.hax],'handlevis','callback');
    
    % After GUI has all elements in it, install context help:
    install_context_help(hfig);
    install_context_menus(hfig);
    
    % Populate GUI with data, limits, etc:
    update_gui([],[],hfig);
    
    % Enable general (non-segmenting) mouse functions:
    install_cursorfcns(hfig,'general');
    set(hfig,'vis','on');
    if isappdata(hfig, 'UIMgr')
      hFrame = getappdata(hfig, 'UIMgr');
      hFrame.Enable = 'on';
    end
  end %function

% ---------------------------------------------------------------
% H E L P    S Y S T E M
% --------------------------------------------------------------
%
% General rules:
%  - Context menus that launch the "What's This?" item have their
%    tag set to 'WT?...', where the '...' is the "keyword" for the
%    help lookup system.
%

%--------------------------------------------------------------
  function HelpWhatsThisBDown(~,~)
    % HelpWhatsThisBDown Button-down function called from either
    %   the menu-based "What's This?" function, or the toolbar icon.
    
    hfig = gcbf;
    hOver = gcbo; % overobj('uicontrol');  % handle to object under pointer
    
    % Restore pointer icon quickly:
    setptr(hfig,'arrow');
    
    % Shut off button-down functions for uicontrols and the figure:
    hChildren = findobj(hfig);
    set(hChildren, 'ButtonDownFcn','');
    set(hfig,'WindowButtonDownFcn','');
    
    % Restore GUI pointers, etc:
    wbmotion_general(hfig);
    
    % Dispatch to context help:
    hc = get(hOver,'uicontextmenu');
    hm = get(hc,'children');  % menu(s) pointed to by context menu
    
    % Multiple entries (children) of context-menu may be present
    % Tag is a string, but we may get a cell-array of strings if
    % multiple context menus are present:
    % Find 'What's This?' help entry
    tag = get(hm,'tag');
    helpIdx = find(strncmp(tag,'WT?',3));
    if ~isempty(helpIdx),
      % in case there were accidentally multiple 'WT?' entries,
      % take the first (and hopefully, the only) index:
      if iscell(tag),
        tag = tag{helpIdx(1)};
      end
      HelpGeneral([],[],tag);
    end
    
  end %function

%--------------------------------------------------------------
  function HelpWhatsThisCB(~, ~)
    % HelpWhatsThisCB Get "What's This?" help
    %   This mimics the context-menu help selection, but allows
    %   cursor-selection of the help topic
    
    % NOTE: Enabling context-help "destroys" the enable-state
    %  of all uicontrols in the GUI.  When the callback completes,
    %  we must restore the enable states.
    
    hfig = gcbf;
    
    % Change pointer icon:
    setptr(hfig,'help');
    
    % Install button-down functions on all uicontrols,
    %  plus the figure itself:
    % uicontrol, axes, line, patch, text
    hChildren = findobj(hfig);
    % No need to set enable states, etc.
    set(hChildren, ...
      'ButtonDownFcn',@HelpWhatsThisBDown);
    set(hfig, ...
      'WindowButtonMotionFcn','', ...
      'WindowButtonUpFcn','', ...
      'WindowButtonDownFcn','');
  end %function

%--------------------------------------------------------------
  function HelpSpecgramdemoCB(~,~)
    %HELPSPECGRAMDEMO Get specgramdemo reference-page help
    
    helpwin(mfilename);
  end %function

%--------------------------------------------------------------
  function HelpProductCB(~,~)
    %HELPRPODUCTCB Opens the Help window with the online doc Roadmap
    %              page (a.k.a. "product page") displayed.
    doc signal/
  end %function

%--------------------------------------------------------------
  function HelpDemosCB(~,~)
    %HELPDEMOSCB Starts Demo window, with the appropriate product's
    %            demo highlighted in the Demo window contents pane.
    demo toolbox signal
  end %function

%--------------------------------------------------------------
  function HelpAboutCB(~,~)
    %HELPABOUTCB Displays version number of product, and copyright.
    
    aboutsignaltbx;
  end %function

%--------------------------------------------------------------
  function HelpGeneral(~,~,tag)
    % HelpGeneral Define CSH text for specgramdemo
    
    hfig = gcbf;
    hco = gcbo;
    
    if nargin<3,
      % Testing purposes only:
      tag = get(hco,'tag');
    end
    
    % Check for legal tag string:
    if ~ischar(tag),
      error(generatemsgid('InvalidParam'),'Invalid context-sensitive help tag.');
    end
    
    % Remove 'WT?' prefix;
    if strncmp(tag,'WT?',3),
      tag(1:3) = [];
    else
      error(generatemsgid('MustBeAString'),'Help tag must be a string beginning with "WT?" prefix.');
    end
    
    ud = get(hfig,'UserData');
    
    % Define text for CSH system
    title = ['Help: ' tag];
    msg = '';
    switch tag
      case ''
        msg = {'';
          'No help available on selected item.'};
        
      case 'Spectrogram image'
        msg = {'';
          'This image displays the spectrogram for the signal currently loaded ';
          'in the viewer.  The spectrogram presents the magnitude of the short-time ';
          'Fourier transform.';
          '';
          'Calculate the spectrogram as follows:';
          '';
          '1. Split the signal into overlapping sections and apply the';
          'window specified by the window parameter to each section.';
          '';
          '2. Compute the discrete-time Fourier transform of each';
          'section with a length Nfft FFT to estimate the short-term ';
          'frequency content of the signal. These transforms ';
          'make up the columns of B. The quantity (length(Nwin) - Nlap)'
          'specifies by how many samples the window will be shifted.';
          '';
          '3. For real input, truncate the spectrogram to the';
          'first (Nfft/2 + 1) points when Nfft is even and (Nfft + 1)/2 when ';
          'Nfft is odd.'};
        
      case 'Zoom Window Panner'
        msg = {'';
          'Shows a panoramic view of the signal which is loaded in the viewer. ';
          'When you zoom in the spectrogram, the corresponding time domain ';
          'portion is highlighed.';
          '';
          'You can zoom the panner by dragging the mouse on the left- and ';
          'right-hand edges of the highlighted zoom region.  Right-click the ';
          'highlighted zoom area to bring up a menu for focusing in on the zoomed ';
          'region'};
        
      case 'Spectrogram Frequency Slice' % Left axes
        if strcmp(ud.plot.left,'spectrogram_freq_slice'),
          msg = {'';
            'This view displays a frequency slice for the current spectrogram. The ';
            'view is updated as you move the crosshair cursor along the frequency '
            'axes (horizontally).'};
        else
          % Change the helpwin title for the PSD case.
          title = 'Help: Signal Power Spectral Density';
          
          msg = {'';
            'Displays the Power Spectral Density (PSD) estimate calculated ';
            'using Welch''s averaged modified periodogram method.'};
          
        end
        
      case 'Spectrogram Time Slice', % Top axes
        msg = {'';
          'This view displays a time slice for the current spectrogram.  The';
          'view is updated as you move the crosshair cursor along the time'
          'axes (vertically).'};
        
      case 'Colorbar'
        msg = {'';
          'The colorbar shows the color scale for the current spectrogram.';
          ''};
        
      case 'Status Bar',
        msg = {'';
          'The Status Bar displays information about the state of the ';
          'Spectrogram Demo, the current operation of the tool, and operation';
          'of the crosshair cursor.'};
        
      case 'Magnitude Readout',
        msg = {'';
          'Displays the magnitude (in dB) of a spectrogram slice.';
          ''};
        
      case 'Frequency Readout',
        msg = {'';
          'Displays frequency values in Hz.';
          ''};
        
      case 'Time Readout',
        msg = {'';
          'Displays time measurements in seconds for the Time Plot ';
          'and the Time Slice'};
        
      case 'Time Plot', % Bottom axes
        msg = {'';
          'Time Plot displays the original signal in its entirety.'};
        
      case 'Colorbar Indicator',
        msg = {'';
          'The colorbar indicator points to the level of the spectrogram.'};
        
      case 'Frequency Crosshair',
        msg = {'';
          'Move the frequency crosshair cursor to pin-point a particular ';
          'frequency location on the spectrogram''s frequency slice axes.'};
        
      case 'Time Crosshair',
        msg = {'';
          'Move the time crosshair cursor to pin-point a particular ';
          'time instance on the spectrogram''s time slice axes.'};
        
      case 'Spectrogram Demo',
        msg = {'';
          'This is the Spectrogram Demo which displays a spectrogram, ';
          'a time plot, and a frequency slice of an input signal';
          '';
          'SPECGRAMDEMO(y,Fs) displays a spectrogram of signal y, assuming a sample ';
          'rate of Fs Hz.  If y is specified but Fs is not, a sample rate of 1 ';
          'Hz is assumed.  If no input arguments are supplied, y and Fs are ';
          'taken from the default data file "mtlb.mat."'};
        
      case 'Spectrogram Window Size',
        msg = {'';
          'Nwin specifies the length of the Periodic Blackman window used in ';
          'this demo. The default value is 256.'};
        
      case 'Spectrogram FFT Size',
        msg = {'';
          'Nfft specifies the FFT length used to calculate the spectrogram. ';
          'This value determines the frequencies at which the discrete-time ';
          'Fourier transform is computed. These values are typically powers ';
          'of two, such as 256 or 512.'};
        
      case 'Spectrogram Overlap'
        msg = {'';
          'Use Nlap to specify the number of samples to overlap the windowed sections.'};
    end
    
    % If no text is defined, simply display the tag.
    if isempty(msg),
      msg = {'';
        ['This is the ' tag '.']};
    end
    
    % Put up message box for help:
    %hmsg = msgbox(msg,title, 'help','modal');
    %CenterFigOnFig(hfig, hmsg);
    
    helpwin(char(msg),title);
  end %function

%--------------------------------------------------------------
  function install_context_help(hfig)
    
    ud = get(hfig,'userdata');
    
    main = {'label','&What''s This?',  ...
      'callback',@HelpGeneral, 'parent'};
    
    setWTC(hfig,main, [ud.himage ud.hax(1)], 'Spectrogram image');
    setWTC(hfig,main, ud.hthumb, 'Zoom Window Panner');
    setWTC(hfig,main, [ud.himage_cbar ud.hax(5)], 'Colorbar');
    setWTC(hfig,main, ud.htext_status, 'Status Bar');
    setWTC(hfig,main, ud.htext_mag, 'Magnitude Readout');
    setWTC(hfig,main, ud.htext_freq, 'Frequency Readout');
    setWTC(hfig,main, ud.htext_time, 'Time Readout');
    setWTC(hfig,main, [ud.htime_plot ud.hax(2)], 'Time Plot');
    setWTC(hfig,main, [ud.htslice_line ud.hax(3)], 'Spectrogram Time Slice');
    setWTC(hfig,main, [ud.hfreq_line ud.hax(4)], 'Spectrogram Frequency Slice');
    setWTC(hfig,main, [ud.hcmap_arrow ud.hax(6)], 'Colorbar Indicator');
    
    setWTC(hfig,main, [ud.hfreq_x ud.hspec_x], 'Frequency Crosshair');
    setWTC(hfig,main, [ud.htime_y ud.htslice_y ud.hspec_y], 'Time Crosshair');
    setWTC(hfig,main, ud.hfig, 'Spectrogram Demo');
    
  end %function

% set context for:
% - readout axis
% - uitoolbar

%--------------------------------------------------------------
  function setWTC(hfig,main,hItem,tagStr)
    % setWT Set the "What's This?" context menu and callback:
    hc = uicontextmenu('parent',hfig);
    uimenu(main{:},hc, 'tag',['WT?' tagStr]);
    set(hItem,'uicontextmenu',hc);
    
  end %function

% ---------------------------------------------------------------
% C O N T E X T   M E N U S
% --------------------------------------------------------------

%-----------------------------------------------------------------
  function install_context_menus(hfig)
    
    install_specgram_mode_menus(hfig);
    install_colorbar_menus(hfig);
    install_freq_slice_menus(hfig);
    install_time_slice_menus(hfig);
    install_time_panner_menus(hfig);
    
  end %function

%-----------------------------------------------------------------
  function install_specgram_mode_menus(hfig)
    
    % Additional menus to prepend to the spectrogram context menu:
    
    ud = get(hfig,'userdata');
    hc = get(ud.himage,'uicontext');  % ud.hax(1) also?
    
    hEntry=[];  % holds handles to each colormap menu item
    opts={hc,'2-D Image',@changeSpecgramMode, 'checked','on'};
    hEntry(end+1) = createContext(opts);
    opts={hc,'3-D Magnitude Plot',@changeSpecgramMode};
    hEntry(end+1) = createContext(opts);
    % disable last menu until feature implemented:
    set(hEntry(end),'enable','off');
    opts={hc,'3-D dB Plot',@changeSpecgramMode};
    hEntry(end+1) = createContext(opts);
    % disable last menu until feature implemented:
    set(hEntry(end),'enable','off');
    
    % Give each menu item a vector of handles to all peer menus
    set(hEntry,'userdata',hEntry);
    
    fixup_context_order(hc);
    
  end %function

%-----------------------------------------------------------------
  function install_colorbar_menus(hfig)
    % Additional menus to prepend to the colorbar context menu:
    
    ud = get(hfig,'userdata');
    hc = get(ud.himage_cbar,'uicontext');  % ud.hax(1) also?
    
    opts={hc,'Colormap',''};
    hCmap = createContext(opts);
    
    hEntry=[];  % holds handles to each colormap menu item
    opts={hCmap,'Jet',@changeCMap, 'checked','on'};
    hEntry(end+1) = createContext(opts);
    opts={hCmap,'Hot',@changeCMap};
    hEntry(end+1) = createContext(opts);
    opts={hCmap,'Gray',@changeCMap};
    hEntry(end+1) = createContext(opts);
    opts={hCmap,'Bone',@changeCMap};
    hEntry(end+1) = createContext(opts);
    opts={hCmap,'Copper',@changeCMap};
    hEntry(end+1) = createContext(opts);
    opts={hCmap,'Pink',@changeCMap};
    hEntry(end+1) = createContext(opts);
    
    opts={hc,'Set Limits',@manual_cmap_limits, 'separator','on'};
    createContext(opts);
    
    opts={hc,'Reset Limits',@reset_cmap_limits};
    createContext(opts);
    
    % Give each menu item a vector of handles to all peer menus
    set(hEntry,'userdata',hEntry);
    
    fixup_context_order(hc);
    
  end %function

%-----------------------------------------------------------------
  function install_freq_slice_menus(hfig)
    
    % Additional menus to prepend to the spectrogram context menu:
    
    ud = get(hfig,'userdata');
    hax_freq = ud.hax(4);
    hc = get(hax_freq,'uicontext');  % ud.hax(1) also?
    
    hEntry=[];  % holds handles to each colormap menu item
    opts={hc,'Marginal (specgram slice)',@changeFreqSliceMode, 'checked','on'};
    hEntry(end+1) = createContext(opts);
    %opts={hc,'Integrated (freq PSD)',@changeFreqSliceMode};
    opts={hc,'Power Spectral Density',@changeFreqSliceMode};
    hEntry(end+1) = createContext(opts);
    set(hEntry(end),'enable','on');
    
    % Give each menu item a vector of handles to all peer menus
    set(hEntry,'userdata',hEntry);
    
    fixup_context_order(hc);
    
  end %function

%-----------------------------------------------------------------
  function install_time_slice_menus(hfig)
    
    % Additional menus to prepend to the spectrogram context menu:
    
    ud = get(hfig,'userdata');
    hax_tslice   = ud.hax(3);
    hc = get(hax_tslice,'uicontext');  % ud.hax(1) also?
    
    hEntry=[];  % holds handles to each colormap menu item
    opts={hc,'Marginal (specgram slice)',@changeTimeSliceMode, 'checked','on'};
    hEntry(end+1) = createContext(opts);
    opts={hc,'Integrated (time zoom)',@changeTimeSliceMode};
    hEntry(end+1) = createContext(opts);
    
    % disable last menu until feature implemented:
    set(hEntry(end),'enable','off');
    
    % Give each menu item a vector of handles to all peer menus
    set(hEntry,'userdata',hEntry);
    
    fixup_context_order(hc);
    
  end %function

%-----------------------------------------------------------------
  function install_time_panner_menus(hfig)
    
    % Additional menus to prepend to the time-panner context menu:
    
    ud = get(hfig,'userdata');
    hthumb = ud.hthumb;  % add to time axis as well?
    hc = get(hthumb, 'uicontext');
    
    % Update the menu on-the-fly:
    set(hc,'callback', @focus_menu_render_callback);
    
    hEntry=[];  % holds handles to each colormap menu item
    
    opts={hc,'Focus In',@focusTimeIn};
    hEntry(end+1) = createContext(opts);
    
    opts={hc,'Previous Focus',@focusTimePrev};
    hEntry(end+1) = createContext(opts);
    
    opts={hc,'Reset Focus',@focusTimeReset};
    hEntry(end+1) = createContext(opts);
    
    % Give each menu item a vector of handles to all peer menus
    set(hEntry,'userdata',hEntry);
    
    fixup_context_order(hc);
    
    update_focus_history_menu(hfig); % pass any focus context menu
    
  end %function

%-----------------------------------------------------------------
  function hMenu=createContext(opts)
    % Helper function to append additional context menus
    args = {'parent',opts{1}, 'label',opts{2}, 'callback',opts{3:end}};
    hMenu=uimenu(args{:});
  end %function

%-----------------------------------------------------------------
  function fixup_context_order(hContext)
    % Put the first context menu entry (the "What's This?" entry)
    %  last in the context menu list, and turn on the separator
    %  for the "What's This?" entry
    childList = get(hContext,'children');
    childList = childList([end 1:end-1]);
    set(hContext,'children',childList);
    set(childList(1),'separator','on');
    
  end %function

%---------------------------------------------------------------
  function changeCMap(~,~)
    
    hco=gcbo; hfig=gcbf;
    % Reset checks on all colormap menu items:
    set(get(hco,'userdata'),'checked','off');
    set(hco,'checked','on');
    
    % Update figure colormap:
    cmapStr = lower(get(hco,'label'));
    cmap = feval(cmapStr);
    set(hfig,'colormap',cmap);
    
  end %function

%---------------------------------------------------------------
  function changeSpecgramMode(~,~)
    
    hco=gcbo;
    % Reset checks on all menu items:
    set(get(hco,'userdata'),'checked','off');
    set(hco,'checked','on');
    
    % Update userdata cache:
    % Update display:
  end %function

%---------------------------------------------------------------
  function changeFreqSliceMode(~,~)
    
    hco=gcbo;
    % Reset checks on all menu items
    set(get(hco,'userdata'),'checked','off');
    set(hco,'checked','on');
    
    % Update userdata cache:
    % Update display:
    left_plot_toggle;
    
  end %function

%---------------------------------------------------------------
  function changeTimeSliceMode(~,~)
    
    hco=gcbo;
    % Reset checks on all menu items
    set(get(hco,'userdata'),'checked','off');
    set(hco,'checked','on');
    
    % Update userdata cache:
    % Update display:
  end %function


% ---------------------------------------------------------------
% F O C U S    S Y S T E M
% --------------------------------------------------------------

%---------------------------------------------------------------
  function push_curr_to_focus_history(hfig)
    
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    
    % focus history is stored in userdata of time-panner axis
    % as either an empty vector or cell, or as
    % a cell-array of 2-element x-lim vector.
    
    % get current time-axis limits
    curr_xlim = get(hax_time,'xlim');
    
    curr_history = get(hax_time,'userdata');
    if isempty(curr_history),
      updated_focus_history = {curr_xlim};
    else
      updated_focus_history = [curr_history {curr_xlim}];
    end
    set(hax_time,'userdata',updated_focus_history);
    
    update_focus_history_menu(hfig);
    
  end %function

%---------------------------------------------------------------
  function hist_xlim = pop_from_focus_history(hfig)
    
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    curr_xlim = get(hax_time,'xlim'); % get current time-axis limits
    
    curr_history = get(hax_time,'userdata');
    if isempty(curr_history),
      % no prev focus info recorded
      warning(generatemsgid('Empty'),'Attempt to pop empty focus stack');
      hist_xlim = curr_xlim;
      
      %im_xdata = get(ud.himage,'xdata');
      %hist_xlim = [min(im_xdata) max(im_xdata)];
    else
      % Pop last history xlim
      hist_xlim = curr_history{end};
      curr_history(end) = [];
      set(hax_time,'userdata',curr_history);
    end
    
    update_focus_history_menu(hfig);
    
  end %function

%---------------------------------------------------------------
  function clear_focus_history(hfig)
    % Remove all previous focus entries
    
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    set(hax_time,'userdata',[]);
    
    update_focus_history_menu(hfig);
    
  end %function

%---------------------------------------------------------------
  function update_focus_history_menu(hfig)
    
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    
    % Update 'Previous Focus' context menu label:
    %
    curr_history = get(hax_time,'userdata');
    histLen = length(curr_history);
    str = 'Previous Focus';
    if histLen>0,
      str = [str ' (' num2str(histLen) ')'];
      ena = 'on';
    else
      ena = 'off';
    end
    
    % Get panner context menu handle:
    hmenu = findobj( get(get(ud.hthumb, 'uicontext'),'children'),'label','Focus In');
    hAllMenus = get(hmenu,'userdata'); % vector of handles to context menus
    hFocusPrev = hAllMenus(2);
    set(hFocusPrev, 'label',str);
    set(hAllMenus(2:3), 'enable',ena);  % Prev and Reset Focus menus
    
  end %function

%---------------------------------------------------------------
  function focus_menu_render_callback(~, ~)
    % Used to update the enable of the "Focus In" menu item
    % Only enabled if thumb_xlim ~= curr_xlim
    
    hfig=gcbf; hparent=gcbo;
    ud = get(hfig,'userdata');
    hAllMenus = get(hparent,'children'); % vector of handles to context menus
    
    % Enable 'Focus on Window' if zoom window is less than entire panner
    %
    hFocusIn = hAllMenus(end);  % 'Focus on Zoom' entry
    hax_time = ud.hax(2);
    curr_xlim = get(hax_time,'xlim'); % get current time-axis limits
    % Get thumbnail xlim vector:
    thumb_xdata = get(ud.hthumb,'xdata');  % current thumbnail patch coords
    thumb_xlim  = [min(thumb_xdata) max(thumb_xdata)]; % convert to xlim
    if ~isequal(curr_xlim, thumb_xlim),
      ena='on';
    else
      ena='off';
    end
    set(hFocusIn,'enable',ena);
    
  end %function

%---------------------------------------------------------------
  function focusTimeIn(~,~)
    
    hfig=gcbf;
    
    % get current time-axis (panner) limits
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    curr_xlim = get(hax_time,'xlim');
    
    % Get thumbnail xlim vector:
    thumb_xdata = get(ud.hthumb,'xdata');  % current thumbnail patch coords
    thumb_xlim  = [min(thumb_xdata) max(thumb_xdata)]; % convert to xlim
    
    if ~isequal(curr_xlim, thumb_xlim),
      push_curr_to_focus_history(hfig);
      
      % Zoom in to thumb limits
      hax_time = ud.hax(2);
      
      set(hax_time,'xlim', thumb_xlim);
      update_axes_with_eng_units(gcbf);
    end
    
  end %function

%---------------------------------------------------------------
  function focusTimePrev(~,~)
    
    hfig=gcbf;
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    
    % Reset to last focus
    xlim = pop_from_focus_history(hfig);
  
    set(hax_time, 'xlim',xlim);
    update_axes_with_eng_units(gcbf);
    
  end %function

%---------------------------------------------------------------
  function focusTimeReset(~,~,hfig)
    % Remove all previous focus entries
    
    if nargin<3, hfig=gcbf; end
    clear_focus_history(hfig);
    
    % Reset focus zoom:
    ud = get(hfig,'userdata');
    hax_time = ud.hax(2);
    im_xdata = get(ud.himage,'xdata');
    
    if length(im_xdata) == 1
      set(hax_time, 'xlim', [0 im_xdata]);
    else
      set(hax_time,'xlim',[min(im_xdata) max(im_xdata)]);
    end
    update_axes_with_eng_units(hfig);
    
  end %function

% ---------------------------------------------------------------
% PARAMETER WINDOW
% --------------------------------------------------------------
% function create_param_gui

% ---------------------------------------------------------------
% AXES UPDATE FUNCTIONS
% --------------------------------------------------------------
  function update_left_plot(hfig)
    % UPDATE_LEFT_PLOT Updates the frequency plot with the appropriate analysis
    
    ud = get(hfig,'UserData');
    mode = ud.plot.left;
    if strcmp(mode,'spectrogram_freq_slice'),
      update_freqslice(hfig);
    else
      update_psdplot(hfig);
    end
    
  end %function

% --------------------------------------------------------------
  function update_freqslice(hfig)
    % UPDATE_FREQSLICE Update the Frequency Slice (on the left axes)
    
    ud = get(hfig,'UserData');
    set(ud.hfreq_line, 'xdata',get_spec_freq(hfig),'ydata',ud.f);
    hax_freq = ud.hax(4);
    
    b = get(ud.himage,'cdata');
    blim = [min(b(:)) max(b(:))];
    spec_ylim = [0 max(ud.f)];
    xlabel('dB');
    set(hax_freq, ...
      'YLim',spec_ylim, ...
      'XLim',blim,...
      'XtickMode','auto');
    set(hax_freq, 'Xtick', return2ticks(hax_freq));
    
    % Update extent of horizontal crosshair:
    set(ud.hfreq_x, 'xdata',blim);
    
  end %function

% --------------------------------------------------------------
  function update_psdplot(hfig)
    % UPDATE_PSDPLOT Update the PSD plot (on the left axes)
    
    ud = get(hfig,'UserData');
    wstate = warning;
    warning off; %#ok
    density = 10*log10(ud.Pxx);
    warning(wstate);
    
    hax_freq = ud.hax(4);
    
    % Update the PSD plot with data and limits
    set(ud.hfreq_line,'Xdata',density,'Ydata',ud.w);
    xlim = [min(density(:)) max(density(:))];
    xlabel('dB/Hz');
    set(hax_freq, ...
      'YLim',     [0 ud.Fs/2],'XLim',xlim,...
      'XTickMode','auto');
    set(hax_freq, 'Xtick', return2ticks(hax_freq));
    
    % Update extent of horizontal crosshair:
    set(ud.hfreq_x, 'xdata',xlim);
    
  end %function

% ---------------------------------------------------------------
% UTILITY FUNCTIONS
% --------------------------------------------------------------
  function new_xtick = return2ticks(haxes)
    % RETURN2TICKS Utility to return two tick marks
    x = get(haxes,'Xtick');
    if length(x)>2,
      new_xtick = [x(1) x(end)];
    else
      new_xtick = x;
    end
    
  end %function

%----------------------------------------------------------
% create_uiframework
  function  hFrame = create_uiframework
    %CREATE_UIFRAMEWORK Create the uiframework.
    
    % Create uimgr UI frame
    hFrame = CreateUIFrame(...
      CreateBaseMenus,...
      CreateBaseToolbar,...
      CreateBaseStatusbar);
    
    % Install plugins
    hPToolbar = install_plugin(hFrame);
    
    % Render uimgr ui objets
    hFrame.render;
    
    % Create play button without audioplayer
    if isempty(hPToolbar) && ISPC;
      render_playbutton(hFrame);
    end
    
    % Top of the uimgr tree
    % technically, this is the only handle we really need to keep
    % all others could be found from this, using hFrame.findchild(...)
    ud.huiframe = hFrame;
    
    % Create parameters dialog object
    hdlgobj = siggui.specgramparamdlg;
    % Other params in the userdata:
    ud.Nwintxt = 'Nwin:';
    ud.Nlaptxt = 'Nlap:';
    ud.Nffttxt = 'Nfft:';
    ud.bGraphic = false;
    ud.param_dlg = [];
    ud.param_dlgobj = hdlgobj;
    
    set(hFrame.WidgetHandle,...
      'closerequest', @close_cb, ...
      'userdata', ud);
    
    % fix g323879
    hPrintBehavior = hggetbehavior(hFrame.WidgetHandle,'Print');
    set(hPrintBehavior,'WarnOnCustomResizeFcn','off');
    
  end %create_uiframework

%----------------------------------------------------------
% CreateBaseMenus
  function hm = CreateBaseMenus
    
    % Menus group
    hm = uimgr.uimenugroup('Menus');
    
    % Files
    mFile = uimgr.uimenugroup('File', '&File');
    
    mFilePrint = uimgr.uimenugroup('PrintOpt');
    mPrint = uimgr.uimenu('Print', '&Print');
    mPrint.WidgetProperties = {'callback',@printdlg_cb};
    mPrintview = uimgr.uimenu('Printview', 'Print Pre&view');
    mPrintview.WidgetProperties = {'callback',@printpreview_cb};
    mFilePrint.add(mPrint, mPrintview);
    
    mFileOpt = uimgr.uimenugroup('FileOpt');
    mClose = uimgr.uimenu('Close', '&Close');
    mClose.WidgetProperties = {'callback', @close_cb};
    mFileOpt.add(mClose);
    mFile.add(mFilePrint, mFileOpt);
    
    % Tools
    mTool = uimgr.uimenugroup('Zoom', '&Tools');
    
    mZoomfull = uimgr.uimenu('Zoomfull', 'Zoom &Full');
    mZoomfull.WidgetProperties = {'callback', @zoom_full};
    
    mZoomin = uimgr.uimenu('Zoomin', '&Zoom In');
    mZoomin.WidgetProperties = {'callback', @zoom_in};
    
    mZoomout = uimgr.uimenu('Zoomout', 'Zoom &Out');
    mZoomout.WidgetProperties = {'callback', @zoom_out};
    
    mZoomgroup = uimgr.uimenugroup('Zoomgroup',mZoomfull, mZoomin, mZoomout);
    
    mParam = uimgr.uimenu('Param', '&Spectrogram Parameters ...');
    mParam.WidgetProperties = {'callback', @param_setting};
    
    mTool.add(mZoomgroup, mParam);
    
    % Windows
    mWin = uimgr.uimenugroup('Windows', '&Windows');
    mWin.WidgetProperties = {'tag','winmenu', ...
      'callback', winmenu('callback')};
    
    % Help
    mHelp = uimgr.uimenugroup('Help', '&Help');
    
    mHelpST = uimgr.uimenugroup('HelpST');
    mSPdemo = uimgr.uimenu('spgdemo', 'Spectrogram Demo &Help');
    mSPdemo.WidgetProperties = {'callback', @HelpSpecgramdemoCB};
    
    mSPCToolbox = uimgr.uimenu('spctoolbox','Signal Processing &Toolbox Help');
    mSPCToolbox.WidgetProperties = {'callback', @HelpProductCB};
    
    mHelpST.add(mSPdemo, mSPCToolbox);
    
    mHelpWs = uimgr.uimenugroup('HelpWs');
    mWhats = uimgr.uimenu('whats', '&What''s This?');
    mWhats.WidgetProperties = {'callback', @HelpWhatsThisCB};
    mHelpWs.add(mWhats);
    
    mHelpDemo = uimgr.uimenugroup('Demo');
    mDemo = uimgr.uimenu('Demos',  '&Demos');
    mDemo.WidgetProperties = {'callback', @HelpDemosCB};
    mHelpDemo.add(mDemo);
    
    mHelpAbout = uimgr.uimenugroup('About');
    mAbout = uimgr.uimenu('abouthelp', '&About Signal Processing Toolbox');
    mAbout.WidgetProperties = {'callback',  @HelpAboutCB};
    mHelpAbout.add(mAbout);
    mHelp.add(mHelpST, mHelpWs, mHelpDemo, mHelpAbout);
    
    hm.add(mFile, mTool, mWin, mHelp);
  end % CreateBaseMenus

%----------------------------------------------------------
% CreateBaesToolbar
  function ht = CreateBaseToolbar
    
    icon_file = 'specgramdemoicons.mat';
    icons = spcwidgets.LoadIconFiles(icon_file);
    
    bPrint = uimgr.uipushtool('Print');
    bPrint.IconAppData = 'print';
    bPrint.WidgetProperties ={...
      'tooltip','Print', ...
      'clickedcallback',@printdlg_cb};
    
    bPrintPre = uimgr.uipushtool('PrintPre');
    bPrintPre.IconAppData = 'printpreview';
    bPrintPre.WidgetProperties = {...
      'tooltip','Print Preview', ...
      'clickedcallback',@printpreview_cb};
    
    bPrintgroup = uimgr.uibuttongroup('Printgroup',bPrint, bPrintPre);
    
    bCenter = uimgr.uipushtool('Center');
    bCenter.IconAppData = 'center_crosshair';
    bCenter.WidgetProperties = {...
      'tooltip','Center Crosshair', ...
      'clickedcallback',@center_cross};
    bCentergroup = uimgr.uibuttongroup('Centergroup', bCenter);
    
    bWhats = uimgr.uipushtool('Whats');
    bWhats.IconAppData = 'whatsthis';
    bWhats.WidgetProperties = {...
      'tooltip','What''s This?', ...
      'clickedcallback',@HelpWhatsThisCB};
    bWhatsgroup = uimgr.uibuttongroup('Whatsgroup', bWhats);
    
    bNormal = uimgr.uipushtool('normal');
    bNormal.IconAppData = 'fullview';
    bNormal.WidgetProperties = {...
      'tooltip','Zoom 100%', ...
      'clickedcallback', @zoom_full };
    
    bZoomin = uimgr.uipushtool('zoomin');
    bZoomin.IconAppData = 'zoominx';
    bZoomin.WidgetProperties = {...
      'tooltip','Zoom In', ...
      'clickedcallback',@zoom_in};
    
    bZoomout = uimgr.uipushtool('zoomout');
    bZoomout.IconAppData = 'zoomoutx';
    bZoomout.WidgetProperties = {...
      'tooltip','Zoom Out', ...
      'clickedcallback',@zoom_out};
    
    bZoomgroup = uimgr.uibuttongroup('zoomgroup', bNormal, bZoomin, bZoomout);
    
    ht = uimgr.uitoolbar('Toolbar',bPrintgroup, bZoomgroup, bCentergroup, bWhatsgroup);
    setappdata(ht, icons);
    
  end % CreateBaseToolbars

%----------------------------------------------------------
% CreateBaseStatusbar
  function hs = CreateBaseStatusbar
    
    hs = uimgr.uistatusbar('StatusBar',@statusBarFcn);
    hsNwin = uimgr.uistatus('Nwin',@(h)statusFcn(h, 'Nwin: 256','Spectrogram Window Size', 80));
    hsNlap = uimgr.uistatus('Nlap', @(h)statusFcn(h,'Nlap: 200', 'Spectrogram Overlap', 80));
    hsNfft = uimgr.uistatus('Nfft',@(h)statusFcn(h,'Nfft: 256', 'Spectrogram FFT Size', 80));
    hs.add(hsNwin, hsNlap, hsNfft);
    
  end % function

%----------------------------------------------------------
% statusBarFcn
  function h = statusBarFcn(h)
    h = spcwidgets.StatusBar(h.GraphicalParent, ...
      'text','Ready');
  end % statusBarFcn

%----------------------------------------------------------
% statusFcn
  function y = statusFcn(h,cname,tooltip, width)
    y = spcwidgets.Status(h.GraphicalParent, ...
      'text', cname, ...
      'width', width, ...
      'tooltip', tooltip);
  end  % function

%----------------------------------------------------------
% CreateUIFrame
  function hFrame = CreateUIFrame(hMenu, hToolbar, hStatusbar)
    
    hFrame = uimgr.uifigure('UIFrame',...
      hMenu,...
      hToolbar,...
      hStatusbar);
    
    hFrame.Visible = 'off';
    hFrame.WidgetProperties = {'numbertitle','off', ...
      'name','Spectrogram Demo', ...
      'menubar','none', ...
      'toolbar','none', ...
      'resizefcn',@resize_fig, ...
      'doublebuffer','off', ...
      'backingstore','off', ...
      'pos',[50 15 550 450],...
      'PaperPositionMode','auto',...
      'DockControls','Off'};
    hFrame.Enable = 'off';
  end % function

end % specgramdemo

% %--------------------------------------------------------------
% % [EOF] specgramdemo.m

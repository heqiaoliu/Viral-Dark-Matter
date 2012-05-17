function varargout = applyfilt(varargin)
%APPLYFILT  Apply Filter utility for SPTool.

%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.12.4.9 $  $Date: 2009/10/16 06:42:56 $
switch varargin{1}

%------------------------------------------------------------------------
% enable = applyfilt('selection',verb.action,msg,SPTfig)
%  respond to selection change in SPTool
% possible actions are
%    'apply'
%  apply Button is enabled when there is exactly one signal selected
%  and one filter selected
case 'selection'
    SPTfig = varargin{4};
    f = sptool('Filters',0,SPTfig);
    s = sptool('Signals',0,SPTfig);
    if length(f)==1  &  length(s)==1
        enable = 'on';
    else
        enable = 'off';
    end
        
    varargout{1} = enable;
    
%------------------------------------------------------------------------
% applyfilt('action','apply')
%  respond to button push in SPTool
case 'action'
    SPTfig = gcf;
    f = sptool('Filters',0,SPTfig);
    s = sptool('Signals',0,SPTfig);
    
    figname = 'Apply Filter';
    okstring = 'OK';
    cancelstring = 'Cancel';
    fus = 5;  % frame / uicontrol spacing
    ffs = 8;
    uh = 24;  % uicontrol height
    lw = 100; % label width
    bw = 100; % button width
    uw = 225; % uicontrol width
    lfs = 5; %label / frame spacing
    lbs = 3; % label / box spacing
    lh = 16; % label height
    
    fp = get(0,'defaultfigureposition');
    w = 2*ffs+lw+lbs+uw;
    h = 5*uh+3*fus+3*ffs;
    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

    fig_props = { ...
       'name'                   figname ...
       'resize'                 'off' ...
       'numbertitle'            'off' ...
       'windowstyle'            'modal' ...
       'createfcn'              ''    ...
       'position'               fp   ...
       'closerequestfcn'        'sbswitch(''applyfilt'',''cancel'')' ...
       'color'                  get(0,'defaultuicontrolbackgroundcolor') ...
       'dockcontrols',          'off',...
       'units'                  'pixels'
       };

    fig = figure(fig_props{:});
    
    cancel_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',cancelstring,...
      'position',[fp(3)/2+ffs/2 ffs bw uh],...
      'callback','sbswitch(''applyfilt'',''cancel'')');
    ok_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',okstring,...
      'position',[fp(3)/2-ffs/2-bw ffs bw uh],...
      'callback','sbswitch(''applyfilt'',''ok'')');
    
    bottomLabelPos = [ffs ffs+uh+ffs lw uh];
    bottomUIControlPos = [ffs+lw+lbs ffs+uh+ffs uw uh];
    
    ud.inputLabel = uicontrol('style','text','string','Input Signal',...
          'units','pixels',...
          'horizontalalignment','right',...
          'position',bottomLabelPos+[0 3*(uh+fus) 0 0]);
    ud.filterLabel = uicontrol('style','text','string','Filter',...
          'units','pixels',...
          'horizontalalignment','right',...
          'position',bottomLabelPos+[0 2*(uh+fus) 0 0]);
    ud.algorithmLabel = uicontrol('style','text','string','Algorithm',...
          'units','pixels',...
          'horizontalalignment','right',...          
          'position',bottomLabelPos+[0 1*(uh+fus) 0 0]);
    ud.outputLabel = uicontrol('style','text','string','Output Signal',...
          'units','pixels',...
          'horizontalalignment','right',...
          'position',bottomLabelPos+[0 0*(uh+fus) 0 0]);
      
    if isfield(f, 'FDAspecs') && isfield(f.FDAspecs, 'current_filt')
%         FDATool filter - use the exact filter object to filter data as default, plus
%         a constructed filter selection
        if ~isfir(f.FDAspecs.current_filt)
            popupString = {f.FDAspecs.current_filt.FilterStructure  'Zero phase IIR (filtfilt)'};
        else
            popupString = {f.FDAspecs.current_filt.FilterStructure  'FFT based FIR (fftfilt)'};
        end
    else
%         Filter Designer filter - make a selection of constructed filters
        popupString = {'Direct Form II Transposed (filter)' ...
                       'Zero phase IIR (filtfilt)'};
        isFIR = (length(f.tf.den)==1);
        if isFIR
            popupString = {popupString{:} 'FFT based FIR (fftfilt)'};
        end
    end
    
    ud.algorithmPopup = uicontrol('style','popupmenu',...
          'units','pixels',...
          'string',popupString,...
          'value',1,...
          'position',bottomUIControlPos+[0 1*(uh+fus) 0 0],...
          'backgroundcolor', 'w');

    ud.inputText = uicontrol('style','edit','string',s.label,...
          'units','pixels',...
          'enable','inactive',...
          'horizontalalignment','left',...
          'position',bottomUIControlPos+[0 3*(uh+fus) 0 0]);
          
    ud.filterText = uicontrol('style','edit','string',f.label,...
          'units','pixels',...
          'enable','inactive',...
          'horizontalalignment','left',...
          'position',bottomUIControlPos+[0 2*(uh+fus) 0 0]);

    labelList = sptool('labelList',SPTfig);
    [ps,fields,FsFlag,defaultLabel] = importsig('fields');
    defaultLabel = uniqlabel(labelList,defaultLabel);

    ud.outputEdit = uicontrol('style','edit',...
           'units','pixels',...
           'backgroundcolor','w',...
           'horizontalalignment','left',...
           'string',defaultLabel,...
           'position',bottomUIControlPos+[0 0*(uh+fus) 0 0]);
    
    ud.flag = '';    
    set(fig,'userdata',ud)
    
    done = 0;
    while ~done
        waitfor(fig,'userdata')

        ud = get(fig,'userdata');
        err = 0;
        
        switch ud.flag
        case 'ok'
            label = get(ud.outputEdit,'string');
            mergeFlag = 0;
            if isempty(label)
                errstr = {'Sorry, you must enter a name for the output signal.'};
                msgbox(errstr,'Error','error','modal')
                err = 1;
            elseif ~isvalidvar(label)
                errstr = {'Sorry, the output signal name you entered' 
                          'is not a valid name.  It must be a valid MATLAB'
                          'variable name.'};
                msgbox(errstr,'Error','error','modal')
                err = 1;
            elseif ~isempty(findcstr(labelList,label))
                str2display = sprintf('By naming the output signal "%s", you are replacing an already existing \nobject in SPTool named "%s." Any objects that depend on "%s" will\nbe altered. Are you sure you want to apply filter?',...
                    label,label,label);
                switch questdlg(...
                        str2display,...
                        'Label Conflict','Yes','No','No');
                    case 'Yes'
                        % OK, good
                   mergeFlag = 1;
                case 'No'
                   err = 1;
                end
            end
            if ~err && isempty(f.Fs) && ~isequal(s.Fs,f.Fs) 
                %Do not compare if Fs is empty which means it's imported
                %filter.
                promptStr = xlate('The signal and filter you have selected have different sampling frequencies. Is it OK to use this filter with the signal''s sampling frequency?');
                switch questdlg(promptStr,'Sampling Frequency Conflict',...
                          'Yes','No','Yes')
                case 'Yes'
                        % OK, good
                case 'No'
                    err = 1;
                end
            end
            if ~err % LET'S FILTER!!!!
                [err,errstr,newSig] = importsig('make',{1,s.data,s.Fs});
                newSig.label = label;
                switch get(ud.algorithmPopup,'value')
                case 1  % filter
                    if isfield(f, 'FDAspecs') && isfield(f.FDAspecs, 'current_filt')
%                   in the case of fdatool filter, use filter object to filter the data
                        for i=1:size(s.data,2)  % loop over columns
                            evalStr = ['newSig.data(:,i) = '...
                                   'filter(f.FDAspecs.current_filt,s.data(:,i));'];
                            try, eval(evalStr);catch ME, err = 1;end  %#ok  
                        end
                    else
                        for i=1:size(s.data,2)  % loop over columns
                            evalStr = ['newSig.data(:,i) = '...
                                   'filter(f.tf.num,f.tf.den,s.data(:,i));'];
                            try, eval(evalStr);catch ME, err = 1;end  %#ok  
                        end
                    end
                case 2  
%                   Added to allow a constructed filter for FDATool filters
                    if isfield(f, 'FDAspecs') && isfield(f.FDAspecs, 'current_filt')
                        for i=1:size(s.data,2)  % filtfilt
                            if ~isfir(f.FDAspecs.current_filt)
                                evalStr = ['newSig.data(:,i) = '...
                                    'filtfilt(f.tf.num,f.tf.den,s.data(:,i));'];
                            else
                                evalStr = ['newSig.data(:,i) = '...
                                    'fftfilt(f.tf.num,s.data(:,i))/f.tf.den;'];
                            end
                            try, eval(evalStr);catch ME, err = 1;end  %#ok  
                        end
                    else % filtfilt
                        for i=1:size(s.data,2)  % loop over columns
                            evalStr = ['newSig.data(:,i) = '...
                                    'filtfilt(f.tf.num,f.tf.den,s.data(:,i));'];
                            try, eval(evalStr);catch ME, err = 1;end  %#ok  
                        end
                    end
                case 3  % fftfilt
                    for i=1:size(s.data,2)  % loop over columns
                        evalStr = ['newSig.data(:,i) = '...
                                 'fftfilt(f.tf.num,s.data(:,i))/f.tf.den;'];
                        try, eval(evalStr);catch ME, err = 1;end  %#ok  
                    end
                end
                if err
                    errstr = {'Sorry, an error occurred during filtering.'
                              'Error message:'
                              ME.message};
                    msgbox(errstr,'Error','error','modal')
                else 
                    if mergeFlag
                        sigs = sptool('Signals');
                        sigLabels = {sigs.label};
                        ind = findcstr(sigLabels,newSig.label);
                        newSig = importsig('merge',sigs(ind),newSig);
                    end
                    sptool('import',newSig,1,SPTfig,1)
                end
            end
                        
        case 'cancel'
           % do nothing and return
           
        end
    
        done = ~err;
        ud.flag = [];
        set(fig,'userdata',ud)
    end
        
    delete(fig)
    
case 'ok'
    fig = gcf;
    ud = get(fig,'userdata');
    ud.flag = 'ok';
    set(fig,'userdata',ud)
    
case 'cancel'
    fig = gcf;
    ud = get(fig,'userdata');
    ud.flag = 'cancel';
    set(fig,'userdata',ud)
    
end

% [EOF] applyfilt.m

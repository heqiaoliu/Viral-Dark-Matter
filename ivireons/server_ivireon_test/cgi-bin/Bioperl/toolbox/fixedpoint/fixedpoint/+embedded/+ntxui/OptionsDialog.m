
classdef OptionsDialog < dialogmgr.DialogContent
    % Implement options dialog for NTX

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:27 $
    
    properties (Access=private) % (SetAccess=private)
        % Handles to widgets within the main dialog panel
        hDisplayRefreshPrompt
        hDisplayRefresh
        
        hPreprocessorPrompt
        hPreprocessor
        hEnvelopeFilterOrderPrompt
        hEnvelopeFilterOrder
    end
    
    properties (SetAccess=private,SetObservable,AbortSet)
        % Properties that require NTX to take immediate action in response
        % to a change in value
        
        % Input Preprocessor
        % 1=none - no preprocessing
        % 2=envelope - compute signal envelope
        OptionsPreprocessor = 1
        
        % Filter order for envelope detection
        EnvelopeFilterOrder = 80
        
        % Display refresh factor
        % Number of updates to silently log before updating the display, providing
        % higher performance at the expense of less frequent visual updates.
        OptionsRefresh = 1
        
    end
    
    properties (Access=private)
        % Internal counter for display decimation
        % Must be initialized to zero
        DisplayRefreshCounter = 0
    end
    
    methods
        function dlg = OptionsDialog(ntx)
            % Setup dialog
            dlg.Name = 'Options';
            dlg.UserData = ntx; % record NTX application handle
        end
    end
    
    methods (Access=protected)
        function createContent(dlg)
            createWidgets(dlg);
            updateWidgets(dlg);
        end
        
        function createWidgets(dlg)
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hParent = dlg.ContentPanel;
            bg = get(hParent,'BackgroundColor');
            ppos = get(hParent,'pos');
            pdx = ppos(3); % initial width of parent panel, in pixels
            
            inBorder = 2;
            outBorder = 2;
            xL = inBorder; % # pix separation from border to widget
            xb = outBorder; % # pix on each side of panel taken by border line
            pdx2 = floor(pdx/2); % midpoint
            dxL = pdx2-10-xb-xL;  % Left side is 10 pix shorter
            xR = xL+dxL+1; % 1-pix gap to start of xR
            dxR = pdx-xR-xb-xL;
            
            y0 = 20+24+2*inBorder;
            
            % Refresh
            x0=2; y0=y0-40; dy=20;
            tip = 'Display refresh rate decreases when > 1';
            dlg.hDisplayRefreshPrompt = uicontrol( ...
                'parent', hParent, ...
                'backgroundcolor',bg, ...
                'tooltip', tip, ...
                'horiz','right', ...
                'enable','inactive', ...  % allow mouse drag on panel
                'units','pix', ...
                'fontsize',8, ...
                'pos',[x0 y0 dxL dy], ...
                'string','Refresh:', ...
                'style','text');
            dlg.hDisplayRefresh = uicontrol( ...
                'parent', hParent, ...
                'backgroundcolor','w', ...
                'units','pix', ...
                'fontsize',8, ...
                'tooltip', tip, ...
                'horiz','left', ...
                'pos',[xR+5 y0+4 dxR-10 dy], ...
                'string',sprintf('%d',dlg.OptionsRefresh), ...
                'callback',@(h,e)setDisplayDecimation(dlg), ...
                'style','edit');
            
            %***********************************
            % Not exposing this control for 10b.
            %***********************************
            % Input preprocessor
%             y0 = y0-dy-5;
%             tip = sprintf(['Input signal preprocessor']);
%             dlg.hPreprocessorPrompt = uicontrol( ...
%                 'parent', hParent, ...
%                 'backgroundcolor',bg, ...
%                 'tooltip', tip, ...
%                 'horiz','right', ...
%                 'fontsize',8, ...
%                 'enable','inactive', ...  % allow mouse drag on panel
%                 'units','pix', ...
%                 'pos',[x0 y0 dxL dy], ...
%                 'string','Preprocessor:', ...
%                 'style','text');
%             dlg.hPreprocessor = uicontrol( ...
%                 'parent', hParent, ...
%                 'backgroundcolor','w', ...
%                 'tooltip',tip, ...
%                 'fontsize',8, ...
%                 'horiz','left', ...
%                 'units','pix', ...
%                 'pos',[xR y0+4 dxR dy], ...
%                 'value',dlg.OptionsPreprocessor, ...
%                 'callback',@(h,e)setPreprocessor(dlg), ...
%                 'string','None|Envelope', ...
%                 'style','popup');
            
%             % Input preprocessor
%             y0 = y0-dy-5;
%             tip = 'Envelope detector filter order';
%             dlg.hEnvelopeFilterOrderPrompt = uicontrol( ...
%                 'parent', hParent, ...
%                 'backgroundcolor',bg, ...
%                 'tooltip', tip, ...
%                 'horiz','right', ...
%                 'fontsize',8, ...
%                 'enable','inactive', ...  % allow mouse drag on panel
%                 'units','pix', ...
%                 'pos',[x0 y0 dxL dy], ...
%                 'string','Filter order:', ...
%                 'style','text');
%             dlg.hEnvelopeFilterOrder = uicontrol( ...
%                 'parent', hParent, ...
%                 'backgroundcolor','w', ...
%                 'tooltip',tip, ...
%                 'fontsize',8, ...
%                 'horiz','left', ...
%                 'units','pix', ...
%                 'pos',[xR y0+4 dxR dy], ...
%                 'callback',@(h,e)setEnvelopeFilterOrder(dlg), ...
%                 'string',sprintf('%d',dlg.EnvelopeFilterOrder), ...
%                 'style','edit');
            
            % Final height
            pdy = 10+24+inBorder;
            set(hParent,'pos',[1 1 pdx pdy]);
        end
        
        function updateWidgets(dlg)
            updateEnvelopeFilterOrderWidgets(dlg);
        end
    end
    
    methods
        % Services provided by OptionsDialog called by NTX
        
        function earlyExit = updateDecimation(dlg)
            % Update display decimation counter
            
            % Maintains a zero-based count of display updates,
            % resets based on decimation factor.
            %
            % refresh=0 displays only the first update and no others
            % refresh=1 displays every update
            % refresh=2 displays every other update, displaying the very first
            % refresh=3 displays every 3rd update, displaying the very first
            % etc
            %
            earlyExit = dlg.DisplayRefreshCounter~=0;
            dlg.DisplayRefreshCounter =  ...
                mod(dlg.DisplayRefreshCounter+1, dlg.OptionsRefresh);
        end
    end
    
    methods
        % Methods to validate and update object properties in response to
        % changes in dialog widgets
        
        function setDisplayDecimation(dlg)
            % Update display decimation factor based on edit box change
            
            str = get(dlg.hDisplayRefresh,'string');
            val = sscanf(str,'%f');
            if isempty(val) || (val~=fix(val)) || (val<=0)
                % Invalid value
                
                % Replace value with previous (valid) value
                val = dlg.OptionsRefresh;
                str = sprintf('%d',val);
                set(dlg.hDisplayRefresh,'string',str);
                
                % Let user know what happened via non-modal dialog
                warndlg('Display Refresh must be an integer value > 0.', ...
                    'Display Refresh','modal');
            end
            
            % Change is accepted: update edit box
            str = sprintf('%d',val);  % replace current value for deblank, etc
            set(dlg.hDisplayRefresh,'string',str);
            
            % Last step: update decimation property
            dlg.OptionsRefresh = val;
        end
        
        function setPreprocessor(dlg)
            % React to a change in hPreprocessor
            dlg.OptionsPreprocessor = get(dlg.hPreprocessor,'value');
            
            % Enable filter order if envelope selected
            updateEnvelopeFilterOrderWidgets(dlg);
        end
        
        function setEnvelopeFilterOrder(dlg)
            % React to a change in hEnvelopeFilterOrder
            str = get(dlg.hEnvelopeFilterOrder,'string');
            val = sscanf(str,'%f');
            if isempty(val) || (val~=fix(val)) || rem(val,2)~=0 || (val<2)
                % Invalid value
                
                % Replace value with previous (valid) value
                val = dlg.EnvelopeFilterOrder;
                str = sprintf('%d',val);
                set(dlg.hEnvelopeFilterOrder,'string',str);
                
                % Let user know what happened via non-modal dialog
                warndlg('Envelope filter order must be an even, positive integer value.', ...
                    'Envelope Filter Order','modal');
            end
            % Change is accepted: update edit box
            str = sprintf('%d',val);  % replace current value for deblank, etc
            set(dlg.hEnvelopeFilterOrder,'string',str);
            % Last step: update property
            dlg.EnvelopeFilterOrder = val;
        end
        
        
        function updateEnvelopeFilterOrderWidgets(dlg)
            % Set initial states of envelope preprocessor widgets
            
            % Set visibility
            set([dlg.hEnvelopeFilterOrderPrompt ...
                dlg.hEnvelopeFilterOrder], 'vis', ...
                uiservices.logicalToOnOff(dlg.OptionsPreprocessor == 2));
            
            % Set order edit box
            set(dlg.hEnvelopeFilterOrder,'string', ...
                sprintf('%d',dlg.EnvelopeFilterOrder));
        end
    end
end

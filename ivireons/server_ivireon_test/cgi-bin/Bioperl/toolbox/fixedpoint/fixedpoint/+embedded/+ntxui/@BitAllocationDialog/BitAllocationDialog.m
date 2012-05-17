classdef  BitAllocationDialog < dialogmgr.DialogContent
    % Implement options dialog for NTX

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3.2.1 $     $Date: 2010/07/06 14:39:02 $


    properties (Access=private)
        % Handles to widgets within the dialog panel
        
        hBASignedPrompt
        hBASigned
        
        hBARoundingPrompt
        hBARounding

        hBAFLPanel
        hBAFLPrompt
        hBAFLMethod
        hBAFLValuePrompt
        hBAFLSpecifyMagnitude
        hBAFLSpecifyBits
        hBAFLExtraBitsPrompt
        hBAFLExtraBits
        
        hBAILPanel
        hBAILPrompt
        hBAILMethod
        hBAILPercent
        hBAILCount
        hBAILUnits
        hBAILValuePrompt
        hBAILSpecifyMagnitude
        hBAILSpecifyBits
        hBAILGuardBitsPrompt
        hBAILGuardBits
        
        % Graphical mode
        hBAGraphicalMode
        
        % Word Length control
        hBAWLPrompt
        hBAWLMethod
        hBAWLValuePrompt
        hBAWLBits
        
        % Combined IL/FL optimization.
        hBAILFLPanel
        hBASpecifyPrompt
        hBAILFLMethod
        hBAILFLValuePrompt
        hBAILFLMaxOverflowPrompt
        hBAILFLPercent
        hBAILFLCount
        hBAILFLUnits
        hBAILFLSpecifyMSBMagnitude
        hBAILFLSpecifyILBits
        hBAILFLGuardBitsPrompt
        hBAILFLGuardBits
        hBAILFLSpecifyLSBMagnitude
        hBAILFLSpecifyFLBits
        hBAILFLExtraBitsPrompt
        hBAILFLExtraBits
       
    end
    
    properties (SetAccess=private,SetObservable,AbortSet)
        % Properties that require NTX to take immediate action in response
        % to a change in value
        
        % Signed mode
        %  1 = Auto
        %  2 = Signed
        %  3 = Unsigned
        BASigned = 1
        
        % Rounding mode
        % 1 = Ceil
        % 2 = Convergent
        % 3 = Floor
        % 4 = Nearest
        % 5 = Round
        % 6 = Zero
        BARounding = 4
        
        % Bit Allocation Fraction Length (BAFL) dialog
        %
        % BAFLMethod
        %   1 = Smallest magnitude, 2 = Specify FL Bits
        BAFLMethod      = 1
        BAFLMagInteractive = 0.01   % Used when initialized to Interactive
        BAFLSpecifyMagnitude = 0.05 % Min magnitude
        BAFLSpecifyBits = 8     % Directly specify number of FL Bits
        BAFLExtraBits   = 0     % Extra FL bits beyond minimum required
        
        % Bit Allocation Integer Length (BAIL) dialog
        %
        % BAILMethod
        %  1 = maximum Overflow, 2 = Largest Magnitude, 3 = Specify IL Bits
        BAILMethod      = 1
        BAILMagInteractive = 10
        BAILPercent     = 0   % Max Overflow Percent target
        BAILCount       = 0   % Max Overflow Count target
        BAILUnits       = 1   % Max Overflow units: 1=Percent, 2=Count
        BAILSpecifyMagnitude = 10  % Max magnitude
        BAILSpecifyBits = 8   % Directly specify number of IL Bits
        BAILGuardBits   = 0   % Guard Bits
        
        % Word Length choice
        % 1 = "Auto"
        % 2 = "Specify"
        BAWLMethod = 2;
        
        % Select a IL or FL specification
        % 1 = Maximum overflow, 2 = Largest magnitude, 3 = IL bits
        % 4 = Smallest magnitude, 5 = FL bits
        BAILFLMethod = 1;
        
        % Indicators for which interactive line was dragged. This used to 
        % check which line was dragged when a word length is specified and graphical
        % mode is turned on. The expected behavior for graphical interaction when a
        % word length is specified is that the entire word length area will shift 
        % based on the line a user drags.
        BAOverflowLineDragged = false;
        BAUnderflowLineDragged = false;
        
        % Bit Allocation Word Length (BAWL) bits
        BAWLBits = 16
        
        % Interactive cursor selection. Value is a logical.
        BAGraphicalMode = false;
        
    end
    
    methods
        function dlg = BitAllocationDialog(ntx)
            % Setup dialog
            dlg.Name = 'Bit Allocation';
            dlg.UserData = ntx; % record NTX application handle
        end
        
        function y = extraLSBBitsSelected(dlg)
            % True if DTX enabled and extra bits selected for Frac Length
            %
            % Property is active in all modes except 'Specify Bits'
            % (BAFLMethod==2)
            %
            %Return false if word length is specified and IL
            %constraint is chosen, since extra precision is not considered
            %when estimating FL.  If Word length is specified, then
            %BAILFLMethod has to be set to "Smallest magnitude (4)" for
            %extra bits to apply. If Word length is not specified, then
            %BAFLMethod has to be set to "smallest magnitude (1)" for extra
            %bits to apply.
            y = (((dlg.BAWLMethod==2) && (dlg.BAILFLMethod==4) && ~dlg.BAGraphicalMode) ||...
                ((dlg.BAWLMethod==1) && (dlg.BAFLMethod==1))) ...
                && (dlg.BAFLExtraBits > 0);
        end
        
        function y = extraMSBBitsSelected(dlg)
            % True if DTX enabled and extra bits selected for Int Length
            %
            % Property is active in all modes except Specify Bits
            % (BAILMethod==2)
            %
            % If Word length is specified, then BAILFLMethod has to be set
            %to one of "Maximum overflow (1)" or "Largest magnitude (2)" for
            %extra bits to apply. If Word length is not specified, then
            %BAILMethod has to be set to "Maximum overflow (1)" or "Largest
            %magnitude (2)" for extra bits to apply.
            y = (((dlg.BAWLMethod==1) && (dlg.BAILMethod~=3)) || ...
                ((dlg.BAWLMethod==2) && (dlg.BAILFLMethod <= 2)) && ~dlg.BAGraphicalMode) && ...
                (dlg.BAILGuardBits > 0);
        end
        
        function setBAILMethod(dlg)
        % Set the Integer Length constraint
            dlg.BAILMethod = get(dlg.hBAILMethod,'value');
        end
        
        function setBAFLMethod(dlg)
        % Set the Fraction Length constraint
            dlg.BAFLMethod = get(dlg.hBAFLMethod,'value');
        end
        
        function setBAILFLMethod(dlg, varargin)
        % Set the Integer or Fraction Length constraint when a Word Length
        % is specified
            if nargin < 2
                dlg.BAILFLMethod = get(dlg.hBAILFLMethod,'value');
            else
                dlg.BAILFLMethod = varargin{1};
                %Set the widget to the updated value.
                set(dlg.hBAILFLMethod,'value',dlg.BAILFLMethod);
            end
            % We now need to set the correct BAILMethod & BAFLMethod based
            % on the selection BAILFL is a union of the two.  The order of
            % this list is very important. Rearranging the IL/FL list
            % without correctly changing this method will lead to bugs.
            % 1 = Maximum overflow, 2 = Largest magnitude, 3 = IL bits 
            % 4 = Smallest magnitude, 5 = FL bits.
            switch dlg.BAILFLMethod
               case 1
                dlg.BAILMethod = 1;
              case 2
                dlg.BAILMethod = 2;
              case 3
                dlg.BAILMethod = 3;
              case 4
                dlg.BAFLMethod = 1;
              case 5
                dlg.BAFLMethod = 2;
            end
        end
        
        function setBAWLMethod(dlg, varargin)
        % Set the Word Length mode.
            if nargin < 2
                dlg.BAWLMethod = get(dlg.hBAWLMethod,'value');
            else
                dlg.BAWLMethod = varargin{1};
                % Set the widget to the updated value.
                set(dlg.hBAWLMethod,'value',dlg.BAWLMethod);
            end
        end
        
        function setBAWLBits(dlg, value)
            % This method provides a way to set the .BAWLBits
            % property outside the dialog. When the incoming data has a
            % fixed-point type, then the properties (WordLength, Fraction
            % Length & Signedness) on the BitAllocation panel are updated
            % to reflect the data type. 
            
            % This is also the callback that gets invoked when the
            % wordlength is set from the dialog.
            if nargin < 2
                str = get(dlg.hBAWLBits,'string');
                value = sscanf(str,'%f');
                if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(value)) || ...
                        (value == 0) || (value > 65535)
                    % Invalid value; replace old value into edit box
                    if isempty(str); str = '[]'; end
                    errordlg(DAStudio.message('FixedPoint:fiEmbedded:WordLengthInvalidValue', str), ...
                        'Word Length','modal');
                    value = dlg.BAWLBits;
                end
            end
            dlg.BAWLBits = value;
            % Update the widget with the value.
            str = sprintf('%d',dlg.BAWLBits); % replace string (removes spaces, etc)
            set(dlg.hBAWLBits,'string',str)
        end
        
        function setBAILUnits(dlg,h)
        % Two widgets use this method as a callback. The Max. overflow
        % widget in the ILFL joint panel and the IL panel. The input
        % 'h' is a handle to the widget that was just changed. Use this
        % handle instead of dlg.hBAILUnits or dlg.hBAILFLUnits
        if isempty(h)
            return;
        end
        if isa(handle(h),'uicontrol') && ishghandle(h)
                dlg.BAILUnits = get(h,'value');
            else
                dlg.BAILUnits = h;
            end
            set(dlg.hBAILUnits,'value',dlg.BAILUnits);
            set(dlg.hBAILFLUnits,'value',dlg.BAILUnits);
        end
        
        function setBAFLBits(dlg, value)
            % This method provides a way to set the .BAFLSpecifyBits
            % property outside the dialog. When the incoming data has a
            % fixed-point type, then the properties (WordLength, Fraction
            % Length & Signedness) on the BitAllocation panel are updated
            % to reflect the data type.
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(value,'allowNegValues'))
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:FractionLengthInvalidValue'),...
                         'Fraction Length','modal');
            else
                dlg.BAFLSpecifyBits = value;

            end
            % Set the widgets to reflect the updated value.
            set(dlg.hBAFLSpecifyBits,'string',sprintf('%g',dlg.BAFLSpecifyBits));
            set(dlg.hBAILFLSpecifyFLBits,'string',sprintf('%g',dlg.BAFLSpecifyBits));
        end
        
        function setBAGraphicalMode(dlg)
        % Turn On/Off the Graphical controls.
            dlg.BAGraphicalMode = get(dlg.hBAGraphicalMode,'value');
        end
        
        function enableBAILPanel(dlg)
        % Make the Integer Length panel visible
            set(dlg.hBAILPanel,'vis','on');
        end
        
        function enableBAFLPanel(dlg)
        % Make the Fraction Length panel visible.
            set(dlg.hBAFLPanel,'vis','on');
        end
        
        function setOverflowLineDragged(dlg,value)
        % Set the value of BAOverflowLine if dragged via cursor.
            dlg.BAOverflowLineDragged = value;
        end
        
        function setUnderflowLineDragged(dlg,value)
        % Set the value of BAUnderflowLine if dragged via cursor.
            dlg.BAUnderflowLineDragged = value;
        end
        
        function setSignedPromptColor(dlg,clrPrompt,clrPulldown,clrText)
        % Set color of signed prompt and widget for warning state
            set(dlg.hBASignedPrompt,...
                'BackgroundColor',clrPrompt,...
                'ForegroundColor',clrText);
            set(dlg.hBASigned,...
                'BackgroundColor',clrPulldown,...
                'ForegroundColor',clrText);
        end
        
        function setSignedMode(dlg, varargin)
        % Update .IsSigned based on user-selected OptionsSigned mode
        % and past histogram data
        if nargin < 2
            dlg.BASigned = get(dlg.hBASigned,'value');
        else
            dlg.BASigned = varargin{1};
            set(dlg.hBASigned,'value',dlg.BASigned);
        end
        end
        
        
        function y = getRoundingMode(dlg)
        % Get the rounding mode from the widget.
            y = dlg.BARounding;
        end
    end
    
    methods (Static)
       % Check value entered on the edit boxes. 
       isValid = isInputValueValid(value, option) 
    end
        
    
    methods (Access=protected)
        % Implement part of create() method defined by Dialog class
        createContent(dlg,hParent)
    end
    
    methods (Access=private)
        % Private methods in external files
        createFLSubdialog(dlg,hPanel)
        createILSubdialog(dlg,hPanel)
        createILFLSubdialog(dlg,hPanel)
        setBAFLWidgets(dlg)
        setBAILWidgets(dlg)
        setBAILFLWidgets(dlg)
    end
    
    methods (Access=private)
        % Enable/disable/hide widget panels
        
        function disableBAFLPanel(dlg)
            % Disable interactive Fraction Length panel controls
            
            hChild = get(dlg.hBAFLPanel,'children');
            set(hChild,'vis','off');
            % Only enable extra bits when Word Length is unspecified and
            % Graphical mode is turned on.
            if (dlg.BAWLMethod == 1) && dlg.BAGraphicalMode
                % Make the Extra FL Bits widget visible if graphical mode
                % is turned on.
                set([dlg.hBAFLExtraBitsPrompt dlg.hBAFLExtraBits],'vis','on');
            end
        end
        
        function disableBAILPanel(dlg)
            % Disable normal Integer Length panel controls
            hChild = get(dlg.hBAILPanel,'children');
            set(hChild,'vis','off');
            % Only enable extra bits when Word Length is unspecified and
            % Graphical mode is turned on.
            if (dlg.BAWLMethod == 1) && dlg.BAGraphicalMode
                % Make the Extra IL Bits widget visible if graphical mode
                % is turned on.
                set([dlg.hBAILGuardBitsPrompt dlg.hBAILGuardBits],'vis','on');
            end
        end
        
        function disableBAWLPanel(dlg)
            % Disable normal Word Length panel controls
            set(dlg.hBAWLValuePrompt,'vis','off','ena','off');
            set(dlg.hBAWLBits,'vis','off','ena','off');
        end
        
        function disableBAILFLPanel(dlg)
            % Disable normal IL/FL panel controls
            hChild = get(dlg.hBAILFLPanel,'children');
            set(hChild,'vis','off');
            set(dlg.hBAILFLPanel,'vis','off');
        end
        
        function enableBAWLPanel(dlg)
        % Enable normal Word Length panel controls
            set(dlg.hBAWLValuePrompt,'vis','on','ena','inactive');
            set(dlg.hBAWLBits,'vis','on','ena','on');
        end
        
        function enableBAILFLPanel(dlg)
            %Enable normal IL/FL panel controls
            set(dlg.hBAILFLPanel,'vis','on');
        end
       
        function hideBAWLPanel(dlg)
            % Make Word Length panel controls invisible
            hChild = get(dlg.hBAWLPanel,'children');
            set(hChild,'ena','off');
            h = [dlg.hBAWLPrompt dlg.hBAWLMethod dlg.hBAWLValuePrompt ...
                dlg.hBAWLBits];
            set(h,'vis','off');
        end
    end
    
    methods (Access=private)
        % React to changes in widget values
        
        function setBAFLCount(dlg)
             str = get(dlg.hBAFLCount,'string');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
                % Invalid value; replace old value into edit box
                val = dlg.BAFLCount;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidUnderflowCount'), ...
                        'Fraction Length','modal');
            end
            set(dlg.hBAFLCount,'string',sprintf('%d',val));
            dlg.BAFLCount = val; % record value last, triggers event
        end
        
        function setBAFLMagEdit(dlg,h)
            % Two widgets use this method as a callback. The smallest
            % magnitude widget in the ILFL joint panel and the FL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAFLSpecifyMagnitude
            % or dlg.hBAILFLSpecifyLSBMagnitude
            str = get(h,'string');
            val = sscanf(str,'%f');
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val, 'allowNonIntegerValues')) || (val == 0)
                % Invalid value; replace old value into edit box
                val = dlg.BAFLSpecifyMagnitude;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidFLMagnitude'),...
                        'Fraction Length','modal');
            end
            
            % Update dialog edit box
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAFLSpecifyMagnitude,'string',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyLSBMagnitude,'string',sprintf('%g',val));
            dlg.BAFLSpecifyMagnitude = val; % record value last, triggers event
        end
        
        function setBAFLMethodTooltip(dlg)
            switch dlg.BAFLMethod
              case 1 % Smallest magnitude
                flm_tip = DAStudio.message('FixedPoint:fiEmbedded:SmallestMagMethodToolTip');
              case 2 % Specify Bits
                flm_tip = DAStudio.message('FixedPoint:fiEmbedded:FLBitsToolTip');
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemessageid('unsupportedEnumeration');
                error(errID, 'Unsupported BAFLMethod (%d)',dlg.BAFLMethod);
            end
            set(dlg.hBAFLMethod,'tooltip',flm_tip);
        end
        
        function setBAFLPercent(dlg)
            str = get(dlg.hBAFLPercent,'string');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNonIntegerValues')) || val>100
                % Invalid value; replace old value into edit box
                val = dlg.BAFLPercent;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidUnderflowPcnt'),...
                        'Fraction Length','modal');
            end
            set(dlg.hBAFLPercent,'string',sprintf('%g',val));
            dlg.BAFLPercent = val; % record value last
        end
        
        function setBAFLSpecifyBits(dlg,h)
            % Two widgets use this method as a callback. The fractional
            % bits widget in the ILFL joint panel and the FL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAFLSpecifyBits
            % or dlg.hBAILFLSpecifyBits
            str = get(h,'string');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNegValues'))
                % Invalid value; replace old value into edit box
                %val = dlg.BAFLSpecifyBits;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:FractionLengthInvalidValue'),...
                        'Fraction Length','modal');
            else
                dlg.BAFLSpecifyBits = val;
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAFLSpecifyBits,'string',sprintf('%g',dlg.BAFLSpecifyBits));
            set( dlg.hBAILFLSpecifyFLBits,'string',sprintf('%g',dlg.BAFLSpecifyBits));
        end
        
        function setBAFLUnits(dlg)
            % Two widgets use this method as a callback. The max
            % underflow widget in the ILFL joint panel and the FL panel.
            dlg.BAFLUnits = get(dlg.hBAILFLUnits,'value');
        end
        
        function setBAILCount(dlg,h)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILCount or dlg.hBAILFLCount
            str = get(h,'string');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
                % Invalid value; replace old value into edit box
                val = dlg.BAILCount;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidOverflowCount'),...
                        'Integer Length','modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILCount,'string',sprintf('%d',val));
            set(dlg.hBAILFLCount,'string',sprintf('%d',val));
            dlg.BAILCount = val; % record value
        end
        
        function setBAILMagEdit(dlg,h)
            % Two widgets use this method as a callback. The Largest
            % magnitude widget in the ILFL joint panel and the IL panel.
            % The input 'h' is a handle to the widget that was just
            % changed. Use this handle instead of dlg.hBAILSpecifyMagnitude
            % or dlg.hBAILFLSpecifyMagnitude
            
            % Change in Integer Length (IL) Maximum Magnitude edit box
            str = get(h,'string');
            val = sscanf(str,'%f');
            % Do not attempt to constrain edit box value to >= LSB (underflow cursor)
            % That's because the LSB is dynamic and may change over time.  We are not
            % going to reject the edit box value here based on a dynamic LSB.  We
            % handle clipping of the recommendation elsewhere.
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val)) || (val == 0)
                % Invalid value; replace old value into edit box
                val = dlg.BAILSpecifyMagnitude;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidILMagnitude'),...
                        'Integer Length','modal');
            end
            % Update dialog edit box
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILSpecifyMagnitude,'string',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyMSBMagnitude,'string',sprintf('%g',val));
            dlg.BAILSpecifyMagnitude = val; % record value
        end
        
        function setBAILMethodTooltip(dlg)
            % Set tooltip for Bit Allocation Integer Length popup tooltip
            switch dlg.BAILMethod
              case 1 % Specify Overflow
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:OverflowToolTip');
              case 2 % Specify Magnitude
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:LargestMagToolTip');
              case 3 % Specify bits
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:ILBitsToolTip');
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemessageid('unsupportedEnumeration');
                error(errID, 'Invalid BAILMethod (%d)', dlg.BAILMethod);
            end
            set(dlg.hBAILMethod,'tooltip',ilm_tip);
        end
        
        function setBAILFLMethodTooltip(dlg)
        % Set the tooltip for the BAILFL joint optimization
        % popup choices.
            switch dlg.BAILFLMethod % .BAILMethod
              case 1 % Maximum Overflow
                ilm_tip =  DAStudio.message('FixedPoint:fiEmbedded:OverflowToolTip');
              case 2 % Largest Magnitude
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:LargestMagToolTip');
              case 3 % Set Integer bits
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:ILBitsToolTip');
              case 4 % Smallest magnitude
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:SmallestMagMethodToolTip');
              case 5 % Set Fraction bits
                ilm_tip = DAStudio.message('FixedPoint:fiEmbedded:FLBitsToolTip');
              otherwise
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemessageid('unsupportedEnumeration');
                error(errID,'Invalid BAILFLMethod (%d)', dlg.BAILFLMethod);
            end
            set(dlg.hBAILFLMethod,'tooltip',ilm_tip);
        end
        
        function setBAILPercent(dlg,h)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILPercent or dlg.hBAILFLPercent
            str = get(h,'string');
            val = sscanf(str,'%f');
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNonIntegerValues')) || val>100
                % Invalid value; replace old value into edit box
                val = dlg.BAILPercent;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidOverflowPcnt'),...
                        'Integer Length','modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILPercent,'string',sprintf('%g',val));
             set(dlg.hBAILFLPercent,'string',sprintf('%g',val));
            dlg.BAILPercent = val; % record value
        end
        
        function setBAILSpecifyBits(dlg,h)
            % Two widgets use this method as a callback. The Max. overflow
            % widget in the ILFL joint panel and the IL panel. The input
            % 'h' is a handle to the widget that was just changed. Use this
            % handle instead of dlg.hBAILSpecifyBits or
            % dlg.hBAILFLSpecifyBits
            str = get(h,'string');
            val = sscanf(str,'%f');
            
            if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val,'allowNegValues'))
                % Invalid value; replace old value into edit box
                val = dlg.BAILSpecifyBits;
                errordlg(DAStudio.message('FixedPoint:fiEmbedded:IntegerLengthInvalidValue'),...
                        'Integer Length','modal');
            end
            % The two widgets point to the same parameter, so they both
            % should reflect the same change.
            set(dlg.hBAILSpecifyBits,'string',sprintf('%g',val));
            set(dlg.hBAILFLSpecifyILBits,'string',sprintf('%g',val));
            dlg.BAILSpecifyBits = val; % record value
        end
    end
end

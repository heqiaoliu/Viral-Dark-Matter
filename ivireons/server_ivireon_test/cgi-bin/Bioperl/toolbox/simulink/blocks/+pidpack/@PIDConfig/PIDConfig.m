classdef PIDConfig
    % pidpack.PIDConfig: Management class for the masked PID Controller and
    % PID Controller (2DOF) blocks in simulink/Continuous and
    % simulink/Discrete.
    
    %   Author(s): Murad Abu-Khalaf , December 17, 2008
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.6 $ $Date: 2010/01/25 22:57:43 $
    
    methods
        function obj = PIDConfig
        end
    end
    
    methods (Static = true)
        
        function ddg_obj = pidDDGCreate(hBlk,action)
            % PIDDDGCREATE   Creates the DDG object for the customized
            % mask.
            if strcmpi(action{1},'OpenFcn')
                ddg_obj = pidpack.PIDMasks(hBlk);
            end
            % NOTE: This assumes the following:
            % set_param(gcb,'DialogController','pidpack.PIDConfig.pidDDGCreate')
            % set_param(gcb,'DialogControllerArgs','OpenFcn')
        end
        
        function updateTunerName(currentblock)
            % UPDATETUNERNAME  Update the name of the PID Tuner's dialog
            if (license('test','simulink_control_design')==1)
                try
                    h = slctrlguis.pidtuner.getInstance(currentblock);
                    if ~isempty(h)
                        h.updateName;
                    end
                catch E %#ok<NASGU>
                end
            end
        end
        
        function closeTuner(currentblock)
            % CLOSETUNER  Close the PID Tuner
            if (license('test','simulink_control_design')==1)
                try
                    h = slctrlguis.pidtuner.getInstance(currentblock);
                    if ~isempty(h)
                        h.close;
                    end
                catch E %#ok<NASGU>
                end
            end
        end
        
        function iconstr = getMaskDisplayString(currentblock)
            % GETMASKDISPLAYSTRING  Generates the Mask display string
            
            blkH = handle(currentblock);
            
            isI = any(blkH.Controller == 'I');
            isD = any(blkH.Controller == 'D');
            
            if strcmp(blkH.TimeDomain,'Continuous-time')
                argstr = '(s)';
            else
                argstr = '(z)';
            end
            iconstr = ['disp(' '''' blkH.Controller argstr '''' ')'];
            
            % Determine mininimum number of inports for the block
            if strcmp(blkH.MaskType,'PID 1dof')
                MINPORTS = 1;
                iconstr =  [iconstr sprintf('\n') ...
                    'port_label(''input'',1, '''');' sprintf('\n') ...
                    'port_label(''output'',1, '''');'];
            elseif strcmp(blkH.MaskType,'PID 2dof')
                MINPORTS = 2;
                iconstr =  [iconstr sprintf('\n') ...
                    'port_label(''input'',1, ''Ref'');' sprintf('\n') ...
                    'port_label(''input'',2, '''');' sprintf('\n') ...
                    'port_label(''output'',1, '''');'];
            else
                error('Unknown MaskType');
            end
            
            aPointer = MINPORTS+1;
            if (isI || isD) && ~strcmp(blkH.ExternalReset,'none')
                aPointer = aPointer + 1;
            end
            
            if strcmp(blkH.InitialConditionSource,'external')
                if isI
                    iconstr = [iconstr sprintf('\n') 'port_label(''input'',' ...
                        num2str(aPointer) ',''\rmI_0'',''texmode'',''on'');'];
                    aPointer = aPointer + 1;
                end
                if isD
                    iconstr = [iconstr sprintf('\n') 'port_label(''input'',' ...
                        num2str(aPointer) ',''\rmD_0'',''texmode'',''on'');'];
                    aPointer = aPointer + 1;
                end
            end
            
            if strcmp(blkH.TrackingMode,'on')
                if isI
                    iconstr = [iconstr sprintf('\n') 'port_label(''input'',' ...
                        num2str(aPointer) ',''TR'',''texmode'',''on'');'];
                end
            end
            
            % Position = [LEFT TOP RIGHT BOTTOM]
            aPosition = get_param(currentblock, 'Position');
            LEFT = aPosition(1); BOTTOM = aPosition(4);
            
            % Get ports numbers and positions
            ports = get_param(currentblock, 'Ports');
            n = ports(1); % Number of ports
            aPortCon = get_param(currentblock,'PortConnectivity');
            
            % Add trigger symbol to the RESET port
            if n>MINPORTS
                RESETPosY = aPortCon(1+MINPORTS).Position(2);
                RESETPosX = aPortCon(1+MINPORTS).Position(1);
                if strcmp(get_param(currentblock,'Orientation'),'right')
                    shifty = BOTTOM - RESETPosY - 4;
                    shiftx = LEFT - RESETPosX - 3;
                elseif strcmp(get_param(currentblock,'Orientation'),'down')
                    shifty = BOTTOM - RESETPosY - 17;
                    shiftx = RESETPosX - LEFT - 6;
                elseif strcmp(get_param(currentblock,'Orientation'),'left')
                    shifty = BOTTOM - RESETPosY - 4;
                    shiftx = RESETPosX - LEFT - 22;
                elseif strcmp(get_param(currentblock,'Orientation'),'up')
                    shifty = RESETPosY - BOTTOM - 2;
                    shiftx = RESETPosX - LEFT - 6;
                end
            end
            
            % Deal with the Outport
            OutputX = aPortCon(end).Position(1);
            OutputY = aPortCon(end).Position(2);
            if strcmp(get_param(currentblock,'Orientation'),'right')
                satshifty = BOTTOM - OutputY - 4;
                satshiftx = OutputX- LEFT-18;
            elseif strcmp(get_param(currentblock,'Orientation'),'down')
                satshifty = BOTTOM - OutputY + 8;
                satshiftx = OutputX - LEFT - 4;
            elseif strcmp(get_param(currentblock,'Orientation'),'left')
                satshifty = BOTTOM - OutputY - 4;
                satshiftx = 3;
            elseif strcmp(get_param(currentblock,'Orientation'),'up')
                satshifty = BOTTOM - OutputY - 16;
                satshiftx = OutputX- LEFT-4;
            end
            
            % Plot triggering symbols
            symbolsString = '';
            if ~strcmp(blkH.Controller,'P')
                if strcmp(blkH.ExternalReset,'rising')
                    triggerString = [...
                        sprintf(['plot([0 4 4 7]+' num2str(shiftx) ',[0 0 8 8]+' num2str(shifty) ');\n']) ...
                        sprintf(['plot([1 4 6]+'   num2str(shiftx) ',[3 6 3]+'   num2str(shifty) ');\n'])
                        ];
                    symbolsString = [symbolsString triggerString];
                elseif strcmp(blkH.ExternalReset,'falling')
                    triggerString = [...
                        sprintf(['plot([0 4 4 7]+' num2str(shiftx) ',[8 8 0 0]+' num2str(shifty) ');\n']) ...
                        sprintf(['plot([1 4 6]+'   num2str(shiftx) ',[6 3 6]+'   num2str(shifty) ');\n'])
                        ];
                    symbolsString = [symbolsString triggerString];
                elseif strcmp(blkH.ExternalReset,'either')
                    triggerString = [...
                        sprintf(['plot([0 4 4 7]+'   num2str(shiftx) ',[0 0 8 8]+' num2str(shifty) ');\n']) ...
                        sprintf(['plot([1 4 6]+'     num2str(shiftx) ',[3 6 3]+'   num2str(shifty) ');\n']) ...
                        sprintf(['plot([0 4 4 7]+8+' num2str(shiftx) ',[8 8 0 0]+' num2str(shifty) ');\n']) ...
                        sprintf(['plot([1 4 6]+8+'   num2str(shiftx) ',[6 3 6]+'   num2str(shifty) ');\n'])
                        ];
                    symbolsString = [symbolsString triggerString];
                elseif strcmp(blkH.ExternalReset,'level')
                    triggerString = sprintf(['plot([0 2 2 5 5 7]+'   num2str(shiftx) ...
                        ',[0 0 8 8 0 0]+' num2str(shifty) ');\n']);
                    symbolsString = [symbolsString triggerString];
                end
            end
            
            % Plot saturation symbol
            if strcmp(blkH.LimitOutput,'on')
                satString = sprintf(['plot([0 4 6 10]+'   num2str(satshiftx) ...
                    ',[0 0 8 8]+' num2str(satshifty) ');\n']);
                symbolsString = [symbolsString satString];
            end
            
            % Finalize the Mask Display string
            iconstr = [iconstr symbolsString];
            
        end
        
        function delete_block_lines(blk)
            % DELETE_BLOCK_LINES  Deletes a block with all connected lines
            if isempty(blk)
                return;
            end
            for cnt=1:length(blk)
                ports = get_param(blk{cnt},'PortHandles');
                for ct=1:length(ports.Inport)
                    in_lines(ct) = get(ports.Inport(ct),'Line');  %#ok<AGROW>
                    if in_lines(ct) ~= -1
                        delete_line(in_lines(ct));
                    end
                end
                for ct=1:length(ports.Outport)
                    out_lines(ct) = get(ports.Outport(ct),'Line'); %#ok<AGROW>
                    if out_lines(ct) ~= -1
                        delete_line(out_lines(ct))
                    end
                end
                delete_block(blk{cnt});
            end
        end
        
        function clearSubsystem(currentblock)
            % CLEARSUBSYSTEM  Deletes all blocks under mask of the PID 1dof
            % and PID 2dof blocks.
            blk = getfullname(currentblock);
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Gain'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Sum'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Integrator'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','DiscreteIntegrator'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Saturate'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Clamping circuit'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Constant'));
            pidpack.PIDConfig.delete_block_lines(find_system(blk,...
                'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','Switch'));
        end
        
        function current  = isBlockDiagramCurrent(currentblock)
            % ISBLOCKDIAGRAMCURRENT Verifies whether the block diagram contained in the
            % Subsystem is current, or requires rewiring.
            
            blk = getfullname(currentblock);
            blkH = handle(currentblock);
            current = true;
            
            % Check if block diagram matches blkH.Controller
            isProportional = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Proportional Gain'));
            isIntegrator   = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Integrator'));
            isFilter       = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Filter'));
            isP = any(blkH.Controller == 'P');
            isI = any(blkH.Controller == 'I');
            isD = any(blkH.Controller == 'D');
            if ( isP ~= isProportional ) || ...
                    ( isI ~= isIntegrator ) || ( isD ~= isFilter )
                current = false;
                return;
            end
            
            % Check if block diagram matches blkH.TimeDomain
            isDiscreteIntegrator = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','BlockType','DiscreteIntegrator'));
            isDiscrete = strcmpi(blkH.TimeDomain,'discrete-time');
            if (isI || isD)
                if ( isDiscrete ~= isDiscreteIntegrator )
                    current = false;
                    return;
                end
            else
                % Do nothing: For P control only, time-domain changes do not impact the
                % block diagram
            end
            
            % Check if block diagram matches blkH.Form
            isIdeal = strcmpi(blkH.Form,'ideal');
            if isP && (isI || isD)   % PID, PI, PD
                h = handle(get_param([blk '/Proportional Gain'],'handle'));
                Src = h.PortConnectivity(1).SrcBlock;
                Src = handle(Src);
                Srcname = Src.Name;
                isPConnectedToSum = strcmpi(Srcname,'Sum');  % Same for PID 1dof and PID 2dof
                if ( isIdeal ~= isPConnectedToSum )
                    current = false;
                    return;
                end
            else
                % Do nothing: For P control and I control, form changes do not impact
                % the block diagram.
            end
            
            
            % Check if block diagram matches blkH.InitialConditionSource
            isI0        = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','I0'));
            isD0        = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','D0'));
            isExternal  = strcmpi(blkH.InitialConditionSource,'external');
            if (isI || isD)
                if ( isExternal ~= (isI0 || isD0) )
                    current = false;
                    return;
                end
            else
                % Do nothing: For P control only, InitialConditionSource changes do not
                % impact the block diagram
            end
            
            
            % Check if block diagram matches blkH.ExternalReset
            isRESET   = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','RESET'));
            isTrigger = ~strcmpi(blkH.ExternalReset,'none');
            if (isI || isD)
                if ( isTrigger ~= isRESET )
                    current = false;
                    return;
                end
            else
                % Do nothing: For P control only, ExternalReset changes do not impact
                % the block diagram
            end
            
            % Check if block diagram matches blkH.LimitOutput
            isSat         = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Saturation'));
            isLimitOutput = strcmpi(blkH.LimitOutput,'on');
            if ( isLimitOutput ~= isSat )
                current = false;
                return;
            end
            
            % Check if block diagram matches blkH.TrackingMode
            isTR = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','TR'));
            isTrackingMode = strcmpi(blkH.TrackingMode,'on');
            if isI
                if( isTrackingMode ~= isTR )
                    current = false;
                    return;
                end
            else
                % Do nothing: Only significant when Integral action is involved.
            end
            
            % Check if block diagram matches blkH.AntiWindupMode
            isKb      = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Kb'));
            isSwitch  = ~isempty(find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','Switch'));
            isBackCalculation = strcmpi(blkH.AntiWindupMode,'back-calculation');
            isClamping = strcmpi(blkH.AntiWindupMode,'clamping');
            isNoWindup = strcmpi(blkH.AntiWindupMode,'none');
            if isI && isLimitOutput
                if ( isBackCalculation && ~isKb )
                    current = false;
                    return;
                elseif ( isClamping && ~isSwitch )
                    current = false;
                    return;
                elseif ( isNoWindup && (isSwitch || isKb) )
                    current = false;
                    return;
                end
            else
                % Do nothing: Only significant when Integral action is involved and the
                % output is saturated.
            end
        end
       
        configPID(currentblock);
        configPID2DOF(currentblock);
        addPorts(currentblock);
        connectIntegrators(currentblock);
        addSatWindupTracking(currentblock);
        addClampingSubsystem(currentblock,posClamping);
        setParam(currentblock);
        
    end
end
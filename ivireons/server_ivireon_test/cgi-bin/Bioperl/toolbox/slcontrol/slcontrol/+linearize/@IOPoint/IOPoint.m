classdef IOPoint < hgsetget
    %
    
    % Linearization Input-Output Point
    
    %  Author(s): John Glass
    %  Revised:
    % Copyright 1986-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:35:09 $
    
    % PUBLIC PROPERTIES
    properties
        Active = 'on';
        Block = '';
        OpenLoop = 'off';
        PortNumber = 1;
        Type = 'in';
        Description = '';
    end
    % PUBLIC METHODS
    methods
        function display(obj)
            % Display the title string
            disp(ctrlMsgUtils.message('Slcontrol:linearize:IODisplayTitle'));
            
            for ct = 1:length(obj)
                % Display the block
                BlockNoLineBreaks = regexprep(obj(ct).Block,'\n',' ');
                str1 = sprintf('hilite_system(''%s'',''find'');',BlockNoLineBreaks);
                str2 = 'pause(1);';
                str3 = sprintf('hilite_system(''%s'',''none'');',BlockNoLineBreaks);
                if usejava('Swing') && desktop('-inuse')
                    str1 = sprintf('<a href="matlab:%s%s%s">%s</a>',str1,str2,str3,BlockNoLineBreaks);
                else
                    str1 = sprintf('%s',BlockNoLineBreaks);
                end
                
                % Display the current IO blockname
                str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayBlockPortInfo',...
                    str1,obj(ct).PortNumber);
                
                % Display the properties for various IO combinations
                if strcmpi(obj(ct).Type,'in')
                    % For obj case the loop opening will always proceed the input
                    % perturbation.
                    str = LocalGetLoopOpeningMessage(obj(ct),str);
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayInputPerturbation',str);
                elseif strcmpi(obj(ct).Type,'out')
                    % For obj case the loop opening will always follow the output
                    % measurement.
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayOutputMeasurement',str);
                    str = LocalGetLoopOpeningMessage(obj(ct),str);
                elseif strcmpi(obj(ct).Type,'inout')
                    % For obj case the loop opening is first, the input perturbation is
                    % second, and then the output measurement is third.
                    str = LocalGetLoopOpeningMessage(obj(ct),str);
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayInputPerturbation',str);
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayOutputMeasurement',str);
                elseif strcmpi(obj(ct).Type,'outin')
                    % For obj case the output measurement is first, the loop opening
                    % is second, and the input perturbation is third.
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayOutputMeasurement',str);
                    str = LocalGetLoopOpeningMessage(obj(ct),str);
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayInputPerturbation',str);
                else
                    % For obj case the output measurement is first, the loop opening
                    % is second, and the input perturbation is third.
                    str = LocalGetLoopOpeningMessage(obj(ct),str);
                end
                
                % Display the IO point name
                try
                    ph = get_param(obj(ct).Block,'PortHandles');
                    signame = get_param(ph.Outport(obj(ct).PortNumber),'Name');
                    if isempty(signame)
                        str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayNoSignalNameUseBlockName',str);
                    else
                        str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplaySignalName',str,signame);
                    end
                catch Ex %#ok<NASGU>
                    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplaySignalNameUnknown',str);
                end
                fprintf('%s\n\n ',str)
            end
        end
        
        function obj = set.Type(obj, NewType)
            if ~any(strcmp({'in','out','inout','outin','none'},NewType))
                ctrlMsgUtils.error('Slcontrol:linearize:InvalidLinearizationPointType')
            else
                obj.Type = NewType;
            end
        end
        
        function changeModelRoot(obj,oldmodel,newmodel)
            for ct = 1:numel(obj)
                obj(ct).Block = regexprep(this(ct).Block, oldmodel, newmodel);
            end
        end
        
        function bool = isIOsUnique(io)
            % isIOsUnique returns true if all io have unique
            % block/port combinations. This is used by LINEARIZE and FRESTIMATE
            %
            bool = true;
            io_str = cell(size(io));
            for dt = length(io):-1:1
                io_str{dt} = sprintf('%s-%d',io(dt).Block,io(dt).PortNumber);
            end
            if numel(io) ~= numel(unique(io_str))
                bool = false;
            end
        end
        
        function objcopy = copy(obj)
            for ct = numel(obj):-1:1
                objcopy(ct) = linearize.IOPoint;
                objcopy(ct).Active = obj(ct).Active;
                objcopy(ct).Block = obj(ct).Block;
                objcopy(ct).OpenLoop = obj(ct).OpenLoop;
                objcopy(ct).PortNumber = obj(ct).PortNumber;
                objcopy(ct).Type = obj(ct).Type;
                objcopy(ct).Description = obj(ct).Description;
            end
        end
    end
end

function str = LocalGetLoopOpeningMessage(obj,str)

if strcmpi(obj.OpenLoop,'on')
    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayLoopOpening',str);
else
    str = ctrlMsgUtils.message('Slcontrol:linearize:IODisplayNoLoopOpening',str);
end
end


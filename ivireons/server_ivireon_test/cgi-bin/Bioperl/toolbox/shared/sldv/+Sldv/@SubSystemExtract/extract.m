function varargout = extract(obj, block, varargin)

%   Copyright 2010 The MathWorks, Inc.

    nargs = nargin - 2;
    showModel = varargin{1};
        
    if nargs==1
        showUI = false;
        isValid = false;
    elseif nargs==2
        showUI = varargin{2};
        isValid = false;
    else            
        showUI = varargin{2};
        isValid = varargin{3};        
    end
    
    if ~islogical(showModel)
        msgId = 'InvalidShowModel';
        msg = xlate(['Invalid usage of %s. ', ...
               'The showModel parameter must specify a logical value.']);
        obj.handleMsg('error', msgId, msg, obj.UtilityName);
    end
    obj.ShowModel = showModel;
    
    if ~islogical(showUI)
        msgId = 'InvalidShowUI';
        msg = xlate(['Invalid usage of %s. ', ...
               'The showUI parameter must specify a logical value.']);
        obj.handleMsg('error', msgId, msg, obj.UtilityName);
    end
    obj.ShowUI = showUI;
    
    if ~islogical(isValid)
        msgId = 'InvalidIsValid';
        msg = xlate(['Invalid usage of %s. ', ...
               'The isvalid parameter must specify a logical value.']);
        obj.handleMsg('error', msgId, msg, obj.UtilityName);
    end
    obj.IsValid = isValid;        

    if obj.IsValid
        obj.SubSystemH = Sldv.utils.getObjH(block);     
        obj.IsAtomicSubchart = Sldv.utils.isAtomicSubchartSubsystem(obj.SubSystemH);
    else    
        [blockH, errStr] = Sldv.utils.getObjH(block);
        msg = xlate(['Invalid usage of %s. ', ...
               'First argument must specify an Atomic Subsystem ', ...
               'or an Atomic Subchart.']);
        msg = sprintf(sprintf('%s',msg),obj.UtilityName);
        if ~isempty(errStr)            
            obj.Status = false;
            obj.ErrMsg = msg;
        elseif  strcmp(get_param(bdroot(blockH), 'BlockDiagramType'), 'library')
            msg2 = xlate(['Atomic Subsystem or Atomic Subchart ', ...
                'should not be located in a library']);
            obj.Status = false;
            obj.ErrMsg = [msg ' ' msg2];
        else
            blockObj = get_param(blockH,'Object');
            if ~blockObj.isa('Simulink.Block') || ~strcmp(blockObj.BlockType, 'SubSystem')
                obj.Status = false;
                obj.ErrMsg = msg;
            else
                ports = blockObj.Ports;
                if (~strcmpi(blockObj.TreatAsAtomicUnit,'on') && ports(3)==0 && ports(4)==0) && ...
                        ~Sldv.utils.isAtomicSubchartSubsystem(blockH)
                    obj.Status = false;
                    obj.ErrMsg = msg;
                else
                    isAtomicSubchart = Sldv.utils.isAtomicSubchartSubsystem(blockH);
                    [status, msg2] = Sldv.SubSystemExtract.checkPorts(blockH);
                    if ~status
                        msg = [msg ' ' msg2];
                        msg = obj.genNonAtomicSSErrorMessage(msg, blockH);
                        obj.Status = false;
                        obj.ErrMsg = msg;                                         
                    else
                        obj.SubSystemH = blockH;
                        obj.IsAtomicSubchart = isAtomicSubchart;
                    end
                end
            end
        end
    end
    
    if obj.Status
        obj.OrigModelH = bdroot(obj.SubSystemH);
        
        slsfnagctlr('Clear', obj.OrigModelH);
        slsfnagctlr('Dismiss', obj.OrigModelH);
        
        obj.invokess2mdl;
        if ~obj.Status
            obj.deriveSs2mdlError;
        else
            obj.fixSubsystemName;
            obj.addInportsForDSRW;
            obj.addTerminators;
            obj.addFcnCallGenerator;
            obj.setFixedStepSolver;
            obj.copySFDebugSettings;
            obj.saveExtractedModel;
            if ~obj.Status
                obj.deriveSsSaveError;
            elseif obj.ExtractionMode==0 
                [solverChanged, msg] = ...
                    Sldv.SubSystemExtract.createForcessDiscreteMsg(obj.ModelH, obj.OrigModelH);
                if solverChanged && ~obj.IsValid
                    sldvshareprivate('util_gen_warning_notrace', ...
                        [obj.MsgIdPref 'ForceDiscrete'], msg);                                   
                end 
            end
        end
    end
    
    varargout{1} = obj.Status;
    varargout{2} = obj.ModelH;
    varargout{3} = obj.ErrMsg;
end

% LocalWords:  UI notrace

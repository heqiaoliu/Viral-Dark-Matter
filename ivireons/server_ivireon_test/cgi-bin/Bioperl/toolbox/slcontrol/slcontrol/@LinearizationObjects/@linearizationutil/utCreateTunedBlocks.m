function [TunedBlocks,vportios] = utCreateTunedBlocks(this,mdl,blockdata,opt)
% UTFINDTUNEDBLOCKS  Create the sisodata.TunedBlock objects for each block 
% that the user is designing
%
 
% Author(s): John W. Glass 18-Jul-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.11.2.2 $ $Date: 2010/07/26 15:40:27 $

% Compile the model if it needs to be compiled
if strcmp(get_param(mdl,'SimulationStatus'),'stopped')
    % Create the model parameter manager
    ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(mdl);
    ModelParameterMgr.loadModels;
    [ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,true,true,[],[],this.linoptions);
    ModelParameterMgr.ModelParameters = ModelParams;
    ModelParameterMgr.ConfigSetParameters = ConfigSetParameters;
    ModelParameterMgr.prepareModels('linearization');
    ModelParameterMgr.compile('lincompile');
    precompiled = false;
else
    precompiled = true;
end

% Initialize the virtual port ios
vportios = handle(NaN(0,1));

try
    % Evaluate the block functions
    for ct = numel(blockdata):-1:1
        block = blockdata(ct).block;
        blockfcn = blockdata(ct).blockfcn;
        % Get the block handle.  This will also test to see if the block
        % exists.
        blockhandle = get_param(block, 'Object');
        
        % If a configuration function is specified use it.  Otherwise
        % query from the block.
        try
            if strcmp(blockhandle.BlockType,'SubSystem')
                % Get the parameters from the mask workspace
                parameterdata = blockhandle.MaskWSVariables;
                for ct2 = length(parameterdata):-1:1
                    % If the parameter is not double valued make it
                    % non-tunable
                    if isa(parameterdata(ct2).Value,'double')
                        parameterdata(ct2).Tunable = 'on';
                    else
                        parameterdata(ct2).Tunable = 'off';
                    end
                end
                blockstruct = feval(blockfcn{:},block,parameterdata);
            else
                blockstruct = feval(blockfcn{:},block);
            end
        catch ConfigFunctionNotFoundException
            if strcmp(ConfigFunctionNotFoundException.identifier,'MATLAB:UndefinedFunction')
                ctrlMsgUtils.error('Slcontrol:controldesign:ConfigFunctionNotFound',blockfcn{1},block)
            else
                throwAsCaller(ConfigFunctionNotFoundException)
            end
        end
        % Check that the input and output port match the valid ports
        % Get the compiled port dimensions
        if isempty(get_param(block,'CompiledPortDimensions'))
            ctrlMsgUtils.error('Slcontrol:linutil:BlockNoLongerInModelReference',block)
        end

        % Find the ports that have scalar signals
        ph = get_param(block,'PortHandles');
        dim = get_param(ph.Inport(blockstruct.Inport),'CompiledPortDimensions');
        indim = prod(dim(2:end));
        dim = get_param(ph.Outport(blockstruct.Outport),'CompiledPortDimensions');
        outdim = prod(dim(2:end));
        if (indim ~= 1) || (outdim ~= 1)
            ctrlMsgUtils.error('Slcontrol:controldesign:NoScalarTunedBlockIO',block,indim,outdim)
        end

        % Create the TunedBlock objects
        if isempty(blockstruct.InvFcn)
            TunedBlocks(ct) = sisodata.TunedMask;
        else
            TunedBlocks(ct) = sisodata.TunedZPK;
            TunedBlocks(ct).Constraints = blockstruct.Constraints;
            TunedBlocks(ct).ZPK2ParFcn = blockstruct.InvFcn;
        end
        InPars                        = blockstruct.TunableParameters;
        TunedBlocks(ct).Identifier    = sprintf('TC%d',ct);
        TunedBlocks(ct).Name          = block;
        TunedBlocks(ct).Parameters    = InPars;
        TunedBlocks(ct).AuxData       = struct('InportPort',blockstruct.Inport,...
            'OutportPort',blockstruct.Outport);
        TunedBlocks(ct).Par2ZpkFcn    = blockstruct.EvalFcn;

        % Get the sample times
        if iscell(TunedBlocks(ct).Par2ZpkFcn)
            zpkTuned = feval(TunedBlocks(ct).Par2ZpkFcn{1},InPars,TunedBlocks(ct).Par2ZpkFcn{2:end});
        else
            zpkTuned = TunedBlocks(ct).Par2ZpkFcn(InPars);
        end

        TunedBlocks(ct).TsOrig = zpkTuned.Ts;

        % Determine C2D/D2C methods
        if strcmpi(opt.RateConversionMethod,'prewarp')
            C2DMethod = {opt.RateConversionMethod, str2double(opt.PreWarpFreq)};
        else
            C2DMethod = {opt.RateConversionMethod };
        end
        TunedBlocks(ct).C2DMethod = C2DMethod;
        TunedBlocks(ct).D2CMethod = C2DMethod;
    end
catch BlockException
    % Terminate the compilation if the model was not compiled to start
    if ~precompiled
        ModelParameterMgr.term;
        ModelParameterMgr.restoreModels;
        ModelParameterMgr.closeModels;
    end
    throwAsCaller(BlockException)
end

ts = opt.SampleTime;
if ts == -1
    % Find the slowest sample time of all of the tunable blocks
    tsall = get(TunedBlocks,{'TsOrig'});
    ts = max([tsall{:}]);
    opt.SampleTime = ts;
end

% Set the sample time of each of the blocks to be at the design sample
% time.
for ct = 1:numel(TunedBlocks)
    TunedBlocks(ct).Ts = ts;
    
    % Update the zpk data
    TunedBlocks(ct).updateZPK;

    if ~isempty(blockstruct.InvFcn)
        TunedBlocks(ct).addListeners;
    end
end

% Terminate the compilation if the model was not compiled to start
if ~precompiled
    ModelParameterMgr.term;
    ModelParameterMgr.restoreModels;
    ModelParameterMgr.closeModels;
end

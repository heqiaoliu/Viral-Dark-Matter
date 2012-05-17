function BlockSub = utEvaluateSpecification(this,blk,blkRemovalData,SpecStruct,FoldBlock)
% UTEVALUATESPECIFICATION
 
% Author(s): John W. Glass 23-Feb-2009
%   Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/04/30 00:43:50 $

if strcmp(SpecStruct.Type,'Expression')
    if ischar(SpecStruct.Specification)
        Specification = slResolve(SpecStruct.Specification,blk);
    else
        Specification = SpecStruct.Specification;
    end
elseif strcmp(SpecStruct.Type,'Function')
    fcn = SpecStruct.Specification;
    % Evaluate Parameters
    ncommas_names = strfind(SpecStruct.ParameterNames,',');
    ncommas_variables = strfind(SpecStruct.ParameterValues,',');
    if (numel(ncommas_names) ~= numel(ncommas_variables))        
        ctrlMsgUtils.error('Slcontrol:linearize:ErrorInConfigurationStructure',getfullname(blk));
    end
    
    if ~isempty(SpecStruct.ParameterNames)
        params = struct('Name',cell(numel(ncommas_names)+1,1),'Value',[]);
        if ~isempty(ncommas_names)
            paramn_str = textscan(SpecStruct.ParameterNames,'%s','delimiter',',');
            paramn_str = paramn_str{1};
            paramv_str = textscan(SpecStruct.ParameterValues,'%s','delimiter',',');
            paramv_str = paramv_str{1};     
        else
            paramn_str = {SpecStruct.ParameterNames};
            paramv_str = {SpecStruct.ParameterValues};
        end
        for ct = 1:numel(paramv_str)
            params(ct).Name = paramn_str{ct};
            params(ct).Value = slResolve(paramv_str{ct},blk);
        end
    else
        params = struct('Name',cell(0,1),'Value',[]);
    end
    % Get the input signals
    inputs = zeros(0,1);
    InputHandles = blkRemovalData.InputHandles;
    [b,m,n] = unique(InputHandles,'first');
    InputHandles = InputHandles(sort(m));
    for ct = 1:numel(InputHandles)
        ph = get_param(InputHandles(ct),'PortHandles');
        p = handle(ph.Outport);
        inputs = [inputs; p.getOutput];
    end
    % Construct input structure
    blkdata = struct('BlockName',getfullname(blk),...
                        'Parameters',params,...
                        'Inputs',inputs,...
                        'nu',blkRemovalData.nInputs,...
                        'ny',blkRemovalData.nOutputs);
    try
        Specification = feval(fcn,blkdata);
    catch Ex
        ctrlMsgUtils.error('Slcontrol:linearize:ErrorUserDefinedBlockLinearizationSpecification',getfullname(blk),fcn,Ex.message)
    end        
else
    ctrlMsgUtils.error('Slcontrol:linearize:ErrorInConfigurationStructure',getfullname(blk));
end
   
BlockSub = struct('Name',getfullname(blk),'Value',Specification,'FoldBlock',FoldBlock);

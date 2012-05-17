function updateBlockParameters(this,TunedBlocks,OptionsStruct)
% UPDATEBLOCKPARAMETERS  Update the Simulink block parameters
%
 
% Author(s): John W. Glass 04-Oct-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2010/04/11 20:40:58 $

% Evaluate the precision if needed
if ~OptionsStruct.UseFullPrecision
    try
        prec = evalScalarParam(linutil,OptionsStruct.CustomPrecision);
    catch Ex
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidCustomPrecisionExpression',OptionsStruct.CustomPrecision);
    end
else
    prec = NaN;
end

try
    % Write the parameters back to the block dialogs
    for ct = 1:length(TunedBlocks)
        blk = TunedBlocks(ct).Name;
        Parameters = TunedBlocks(ct).getProperty('Parameters');
        Tunable = {Parameters.Tunable};
        TunableIndex = find(strcmp(Tunable,'on'));
        len = length(TunableIndex);
        if len>0
            params = cell(len,1);
            strVal = cell(len,1);
            for ct2 = 1:len
                % get parameter value
                val = Parameters(TunableIndex(ct2)).Value;
                % Write the parameter value according to class type
                strvalue = computeParameterString(this,val,prec);
                % store in the cell
                params{ct2} = Parameters(TunableIndex(ct2)).Name;
                strVal{ct2} = strvalue;
            end
            % update block parameter
            slctrlguis.updateBlockParameter(blk,params,strVal);
        end
    end
catch Ex
    if strcmp(Ex.identifier,'Simulink:Commands:InvSimulinkObjectName')
        ctrlMsgUtils.error('Slcontrol:controldesign:ModelNotOpenToWriteBlockParameters',TunedBlocks(ct).Name);
    elseif strcmp(Ex.identifier,'MATLAB:MultipleErrors')
        ctrlMsgUtils.error('Slcontrol:controldesign:CannotWriteBlockParameters',TunedBlocks(ct).Name,Ex.cause{1}.message)
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:CannotWriteBlockParameters',TunedBlocks(ct).Name,Ex.message)
    end
end

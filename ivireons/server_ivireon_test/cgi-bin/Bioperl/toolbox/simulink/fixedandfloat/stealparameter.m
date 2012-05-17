function outvalue = stealparameter( curBlock, paramNameStr, invalue )
% STEALPARAMETER used in Fixed Point Autoscaling to get parameters
%   values hidden under one or more layers of masks.
%
%    See also AUTOFIXEXP.

% Copyright 1994-2006 The MathWorks, Inc.
% $Revision: 1.10.4.3 $  
% $Date: 2006/05/27 18:23:28 $

outvalue = invalue;

if strcmp('Simulink.NumericType',class(invalue))
    outvalue.IsAlias = false;
end

% Some blocks need to supply a block path and the name of a signal.
% This is achieved by making the first input argument a cell array. 
% The first element is the block path and the second is the signal name.
% 
% The approach of optional trailing input arguments is deliberately
% not used.  fixpt_instrument_purge depends on invalue being the last
% input argument.  
%
% cells are used instead of structs because it is simpler to form the
% necessary string to be used in autoscaling instrumentation
% 
if iscell(curBlock)
    signalName = curBlock{2};
    curBlock = curBlock{1};
else
    signalName = '';
end

badGet    = true;
wrongRoot = false;

try
    refAutoScaleData = SimulinkFixedPoint.AutoScaleData.getRefAutoScaleDataFromModel(curBlock);

    iFound = refAutoScaleData.findIndexToRecordFromPathSigWithAppend(curBlock,signalName);

    refAutoScaleData.enrichedFixPtSimRanges{iFound}.Parameters.(paramNameStr).paramValue = invalue;

    wrongRoot =  ~strcmp( strtok(curBlock,'/'), ...
                          bdroot(refAutoScaleData.topSubSystemToScale) );

    badGet = false;
catch
end

if badGet

    error('SimulinkFixedPoint:stealparameter:corruption',...
          ['The Simulink model %s contains corrupt Fixed-Point autoscaling ' ... 
           'instrumentation.  At the MATLAB command prompt, run the function ' ...
           'fixpt_instrument_purge to remove the corrupt instrumentation.'], ...
          bdroot);
    
elseif wrongRoot

    error('SimulinkFixedPoint:stealparameter:wrongbdroot',...
          ['The Simulink model %s contains corrupt Fixed-Point autoscaling ' ... 
           'instrumentation.  The instrumentation specifies a different ' ...
           'model.  At the MATLAB command prompt, run the function ' ...
           'fixpt_instrument_purge to remove the corrupt instrumentation.'], ...
          bdroot);
end

function [ConfigSetParams,ModelParams] = createLinearizationParams(this,useModelx0,useModelu,io,starttime,options,varargin)
% CREATELINEARIZATIONPARAMS  Create the default linearization parameter
% structure.  The flag, useModelx0 and useModelu is a flag to determine
% whether to overload the model LoadInitialState and LoadInitialInput
% flags.  This is needed for the case of the simulation snapshot at t = 0.
%
 
% Author(s): John W. Glass 25-Oct-2005
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.7.2.1 $ $Date: 2010/07/26 15:40:25 $

if numel(varargin) > 0
    DisableWarnings = varargin{1};
else
    DisableWarnings = true;
end    

if DisableWarnings
    ConfigSetParams = createDisableWarningParameters(this);
else
    ConfigSetParams = struct;
end

ConfigSetParams.BufferReuse = 'off';
ConfigSetParams.BlockReduction = 'off';
ConfigSetParams.InlineParams = 'on';

ModelParams = struct('AnalyticLinearization','on','Dirty','on');

% Set flag for using the linearization ports
if isempty(io)
    ModelParams.UseAnalysisPorts = 'off';
else
    ModelParams.UseAnalysisPorts = 'on';
    iostruct = linearize.createSCDPotentialLinearizationIOsStructure(io);
    ModelParams.SCDPotentialLinearizationIOs = iostruct;
end

if ~useModelx0
    ConfigSetParams.LoadInitialState = 'off';
    ConfigSetParams.StartTime = sprintf('%.17g',starttime);
    ConfigSetParams.StopTime = sprintf('%.17g',starttime+1);
    ConfigSetParams.OutputOption = 'RefineOutputTimes';
end

if ~useModelu
    ConfigSetParams.LoadExternalInput = 'off';
end

if strcmp(options.UseBusSignalLabels,'on')
    % Use bus signal names
    ConfigSetParams.StrictBusMsg = 'ErrorOnBusTreatedAsVector';
end

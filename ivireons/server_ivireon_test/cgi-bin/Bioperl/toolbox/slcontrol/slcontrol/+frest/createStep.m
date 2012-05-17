function out = createStep(varargin)
% frest.createStep create a MATLAB timeseries out which has a step input
% signal.
%
%   out = frest.createStep('param',val,...) creates a MATLAB timeseries
%   which has a step input signal with the specified parameter values.
%
%   Available parameters for step input are:
%       'Ts',       The sample time of the step input. Default value is
%       1e-3.
%       'StepTime', The time, in seconds, when the output jumps from 0 to
%       StepSize parameter. The default is 1 second. 
%       'StepSize', The value of the step signal after time reaches and
%       exceeds the 'StepTime' parameter. The default is 1.
%       'FinalTime', The final time of the step input signal in seconds.
%       The default is 10 seconds.
%
%   See also frestimate, frest.simCompare

%  Author(s): Erman Korkut 01-Apr-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2010/02/17 19:07:45 $

% Error checking
% Check number of input & output arguments
error(nargchk(0,8,nargin));
error(nargoutchk(1,1,nargout));
step_param = struct('Ts',1e-3,'StepTime',1,'StepSize',1,'FinalTime',10);
% Process input arguments
for ct = 1:numel(varargin)/2
    name = varargin{2*ct-1};
    % Error check for the parameter
    if ~any(strcmp(name,{'Ts', 'StepTime', 'StepSize', 'FinalTime'}))
        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterNameStep',name);
    end
    val = varargin{2*ct};
    % Error check for the value
    if ~(isa(val,'double') && isscalar(val))
        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterValueStep');        
    end
    % Set the parameter value
    step_param.(name) = val;
end
% Check that StepTime is smaller than FinalTime
if step_param.StepTime >= step_param.FinalTime
    ctrlMsgUtils.error('Slcontrol:frest:InvalidStepTimeStep',...
        sprintf('%g',step_param.StepTime),sprintf('%g',step_param.FinalTime));
end
% Create the signal
t = 0:step_param.Ts:step_param.FinalTime;
y = zeros(size(t));
step_ind = find(t>=step_param.StepTime,1,'first');
y(step_ind:end) = step_param.StepSize;
% Write it as a MATLAB timeseries
out = timeseries(y(:),t);
out.Name = ctrlMsgUtils.message('Slcontrol:frest:TimeseriesStep');
out.DataInfo.Interpolation.Name = 'Zero-order hold';

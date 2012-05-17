function msfcn_frame_gen(block)
% Level-2 MATLAB file S-Function.
%  Square Function Generator for Frame-Based Signals
%
%  The signal amplitude is passed as a block parameter.
%  The number of samples per frame is passed as a block parameter.
%  The period (number of samples) is passed as a block parameter.
%  The duty cycle is fixed to period/2.
%
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/12/07 20:47:34 $
        
setup(block);

function setup(block)
  % Register the number of ports.
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;
  
  % In Accelerator mode, the block runs on TLC.
  block.SetAccelRunOnTLC(true);

  % Set up the outport data-type properties.
  block.OutputPort(1).DatatypeID  = 0;
  block.OutputPort(1).Complexity  = 'Real';
  
  % Set up the outport sampling mode.
  block.OutputPort(1).SamplingMode = 'Frame';
  
  % Register the parameters.
  block.NumDialogPrms     = 4;
  block.DialogPrmsTunable = {'Nontunable','Nontunable','Nontunable','Nontunable'};
  
  % Set the output port dimensions.
  nSamples = block.DialogPrm(2).Data;
  nFrames  = length(block.DialogPrm(1).Data);
  block.OutputPort(1).Dimensions = [nSamples,nFrames];
  
  % Register the block sampling time.
  sampleTime = block.DialogPrm(4).Data;
  block.SampleTimes = [sampleTime*nSamples 0];
  
  % Register the block methods.
  block.RegBlockMethod('CheckParameters',         @CheckPrms);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('WriteRTW',                @WriteRTW);
  
function CheckPrms(block)
  % Check the validity of the parameters.
  p1 = block.DialogPrm(1).Data; % Amplitude
  p2 = block.DialogPrm(2).Data; % nSample
  p3 = block.DialogPrm(3).Data; % Period
  p4 = block.DialogPrm(4).Data; % sampleTime
  
  if sum(isnan(p1)+isinf(p1))
    error('Invalid signal magnitude parameter. Nan and inf are not allowed as parameter values.');
  end
  if ~sum(~isreal(p1)+isvector(p1))
    error('Invalid signal magnitude parameter. Value should be a real scalar or vector.');
  end
  if sum(isnan(p2)+isinf(p2))
    error('Invalid number of samples per frame parameter. Nan and inf are not allowed as parameter values.');
  end
  if ~prod(isreal(p2).*isscalar(p2).*(p2>0))
    error('Invalid number of samples per frame parameter. Value should be a real positive scalar.');
  end
  if sum(isnan(p3)+isinf(p3))
    error('Invalid period (in samples) parameter. Nan and inf are not allowed as parameter values.');
  end
  if ~prod(isreal(p3).*isscalar(p3).*(p3>0))
    error('Invalid period (in samples) parameter. Value should be a real positive scalar.');
  end
  if (p3<2)
    error('Invalid period (in samples) parameter. Period should be larger than 1.');
  end
   if sum(isnan(p4)+isinf(p4))
    error('Invalid sample time parameter. Nan and inf are not allowed as parameter values.');
  end
  if ~prod(isreal(p4).*isscalar(p4).*(p4>0))
    error('Invalid sample time parameter. Value should be a real positive scalar.');
  end
  
  function DoPostPropSetup(block)
   % Set up the dwork scalar or vector.
  block.NumDworks = 1;
  
  block.Dwork(1).Name = 'count';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 0;
  block.Dwork(1).UsedAsDiscState = 1;


function Start(block)
  % Initialize the data.
  block.Dwork(1).Data = 0;
    
function Output(block)
  % Output Function for Frame-Based Signals
  
  % Retrieve the parameters.
  Ampl     = block.DialogPrm(1).Data;
  nSamples = block.DialogPrm(2).Data;
  Period   = block.DialogPrm(3).Data;
  nChan    = length(Ampl);
  
  % Allocate space for the output signal.
  outData = zeros(nSamples,nChan);
  
  % Obtain the output.
  count = block.Dwork(1).Data;
  for i=1:nSamples
      if( (count >= Period/2) && (count < Period) )
        outData(i,:) = Ampl;
      end
      count = mod(count+1 , Period);
  end
  
  % Update the output.
  block.OutputPort(1).Data = outData;
  
  % Update the states. (No update function is needed.)
  block.Dwork(1).Data = count;
        
function WriteRTW(block)
  % Save the parameters to an RTW file for code generation.  
   p2 = sprintf('%d', block.DialogPrm(2).Data);
   p3 = sprintf('%d', block.DialogPrm(3).Data);
 
  block.WriteRTWParam('matrix', 'Amplitude', block.DialogPrm(1).Data);
  block.WriteRTWParam('string', 'nSample'    , p2);
  block.WriteRTWParam('string', 'Period'     , p3);
  

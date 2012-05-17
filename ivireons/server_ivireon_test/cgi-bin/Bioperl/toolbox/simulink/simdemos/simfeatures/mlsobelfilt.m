function mlsobelfilt(block)
% Level-2 MATLAB file S-function for applying Sobel filtering  
% (image edge detection demonstration).
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $    
  
  setup(block);

%endfunction

function setup(block)
  
  %% Register dialog parameter: edge direction 
  block.NumDialogPrms = 1;
  block.DialogPrmsTunable = {'Tunable'};
 
  %% Register ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;
  
  %% Setup port properties
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  block.InputPort(1).DatatypeID   = 3;
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Overwritable = false; % No in-place operation
  
  block.OutputPort(1).DatatypeID   = 3;
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register block methods (through MATLAB function handles)
  block.RegBlockMethod('Outputs', @Output);
  block.RegBlockMethod('WriteRTW',@WriteRTW);

  %% Block runs on TLC in accelerator mode.
  block.SetAccelRunOnTLC(true);

%endfunction

function  g = local_sobel_filt(f, dir)
  
  %% Sobel filter coefficients
  h = [1 2 1; 0 0 0; -1 -2 -1];
  
  if dir == 1 % Vertical
    g = abs(filter2(h,f));
  elseif dir == 2 % Horizontal
    g = abs(filter2(h',f));
  else % All
    g = abs(filter2(h, f)) + abs(filter2(h',f));
  end
  
  %% Prevent overflow when converting to uint8
  g(g>255) = 255;
  
  g = uint8(round(g));
  
%endfunction
  
%%
%% Block Output method: Perform Sobel filtering
%%
function Output(block)
  
  dir = block.DialogPrm(1).Data;
  block.OutputPort(1).Data = local_sobel_filt(block.InputPort(1).Data, dir);
%endfunction

function WriteRTW(block)

  dir = sprintf('%d',block.DialogPrm(1).Data);
  
  block.WriteRTWParam('string', 'Direction', dir);

%endfunction

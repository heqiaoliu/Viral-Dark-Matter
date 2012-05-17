function mlloadmovie(block)
% Level-2 MATLAB file S-function for loading movie 
% (image edge detection demonstration).
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  
  
  setup(block);

%endfunction

function dat = getData(block, flag, slice)
  persistent imgdata;
  dat = [];
  if flag == 0
    filename = block.DialogPrm(1).Data;
    load(filename);

    imgdata = [];
    
    for i = 1:length(img)
      imgdata(i).frame = img(i).frame;
    end

    dat = imgdata(1).frame;
  elseif flag == 1
    dat = imgdata(slice).frame;
  elseif flag == 2
    dat = length(imgdata);
  else
    clear imgdata
  end
%endfunction

function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;
  
  %% Setup functional port properties
  block.SetPreCompOutPortInfoToDynamic;

  block.OutputPort(1).DatatypeID   = 3; % uint8
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';

  try
    dat = getData(block, 0, 0);
  catch %#ok<CTCH>
    error('simdemos:mlloadmovie:errorload','Cannot load file %s', block.DialogPrm(1).Data);
  end

  block.OutputPort(1).Dimensions = size(dat);
  
  %% Register parameters
  block.NumDialogPrms     = 1;
  block.DialogPrmsTunable = {'Nontunable'};

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);
  block.RegBlockMethod('Outputs',                 @Output);
  
%endfunction
  
function DoPostPropSetup(block)
  
  %% Setup Dwork
  block.NumDworks = 1;
  
  %% [Slice maxSlice]
  block.Dwork(1).Name         = 'slice';
  block.Dwork(1).Dimensions   = 2;
  block.Dwork(1).DatatypeID   = 0;
  block.Dwork(1).Complexity   = 'Real';

%endfunction

function Start(block)

  %% Initialize Dwork
  dData = [1 getData(block, 2, 0)];
  block.Dwork(1).Data = dData;
%endfunction
  
function Output(block)
  dData    = block.Dwork(1).Data;
  slice    = dData(1);
  maxSlice = dData(2);
  if slice > maxSlice
    slice = 1;
  end
  block.OutputPort(1).Data = getData(block, 1, slice);
  block.Dwork(1).Data      = [slice+1 maxSlice];
%endfunction


function mlplaymovie(block)
% Level-2 MATLAB file S-function for playing movies  
% (image edge detection demonstration).
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $    

  setup(block);

%endfunction

function setup(block)
  
  %% Register number of ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 0;
  
  %% Setup functional port properties
  block.SetPreCompInpPortInfoToDynamic;

  block.InputPort(1).DatatypeID   = 3; %uint8
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  
  %% Register dialog parameters
  block.NumDialogPrms = 2;
  block.DialogPrmsTunable = {'Tunable','Tunable'};

  %% Set the block simStateCompliance to none.
  % This will ensure that the handle store in dwork is not saved and restored
  block.SimStateCompliance = 'HasNoSimState';

  %% Register block methods
  block.RegBlockMethod('SetInputPortDimensions',  @SetInpPortDims);
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Start',                   @Start);
  block.RegBlockMethod('Outputs',                 @Output);

%endfunction

function SetInpPortDims(block,idx,di) %#ok<INUSL>
  block.InputPort(1).Dimensions = di;
%endfunction

function DoPostPropSetup(block)
  block.NumDworks             = 1;
  block.Dwork(1).Name         = 'fighandle';
  block.Dwork(1).Dimensions   = 1;
  block.Dwork(1).DatatypeID   = 0;
  block.Dwork(1).Complexity   = 'Real';
%endfunction

function Start(block)
  hFig = figure(1);
  
  set(hFig, 'NumberTitle', 'off', ...
            'Name', 'Movie Screens', ...
            'BackingStore','off', ...
            'Position', [13 435 1236 285], ...
            'MenuBar', 'none');
  
  subplotnum = block.DialogPrm(1).Data;
  s = subplot(subplotnum);
  h = image(uint8(zeros(block.InputPort(1).Dimensions)));
  axis('equal')
  set(s, 'xlim', [1 block.InputPort(1).Dimensions(2)])
  set(s, 'ylim', [1 block.InputPort(1).Dimensions(1)])
  set(s, 'ytick', [])
  set(s, 'xtick', [])
  set(s, 'FontWeight', 'bold', 'FontSize', 14);
  ttl = block.DialogPrm(2).Data;
  title(ttl);
  colormap(gray(256))
  block.Dwork(1).Data = h;
%endfunction
  
function Output(block)
  h = block.Dwork(1).Data;
  if ishghandle(h,'image')
    set(h, 'CData', block.InputPort(1).Data);
     drawnow('expose')  
  else
    set_param(bdroot,'SimulationCommand','stop');  
  end
%endfunction


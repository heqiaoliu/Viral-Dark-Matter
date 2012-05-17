function sfunlin(block) 
% S-function for snapthot linearization block
%
%  See also LINSETUP, LINMOD, DLINMOD

%  Copyright 1990-2008 The MathWorks, Inc.
%  $Revision $ 
setup(block);

function setup(block)
    block.NumInputPorts = 0;
    block.NumOutputPorts = 0;
    
    block.NumDialogPrms = 2;
    block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};
    block.SampleTimes = [-1 0];

    block.RegBlockMethod('Outputs', @Output);
    
    var = block.DialogPrm(1).Data;
    evalin('base', [var '=[];']);
%endfunction


function Output(block)
        
    var = block.DialogPrm(1).Data;
    ts  = block.DialogPrm(2).Data;
    
    
    % Request the engine to obtain Jacobian and then
    % call linearization callback
    block.RequestLinearization(@lincallback, {[], var, ts});
    
%endfunction

function lincallback(J, arg)
% LINCALLBACK callback function for triggered linearization block
%  
%    lincallback(J, varName, samplePeriod) takes the Jacobian snapshot J,
%  post-process it using dlinmod_post and append the result to the struct
%  variable 'varName' in the base workspace.
%  
varName = arg{2};
samplePeriod = arg{3};

t = J.time;

if samplePeriod==0
    sys = sl('dlinmod_post', J, bdroot, t, samplePeriod, [], [], 1);
else
    sys = sl('dlinmod_post', J, bdroot, t, samplePeriod, [], [], 0);
end
    
if ~evalin('base', sprintf('exist(''%s'', ''var'')', varName))
    assignin('base', varName, sys);
else
    var = evalin('base', varName);
    if isempty(var)
        var = sys;
    else 
        var(end+1) = sys;
    end
    assignin('base', varName, var);
end
%endfunction 


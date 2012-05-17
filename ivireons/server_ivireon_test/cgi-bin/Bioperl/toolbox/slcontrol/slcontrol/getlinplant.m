function [sysp,sysc] = getlinplant(block,op,varargin)
%GETLINPLANT Compute open loop plant model from Simulink diagram.
%
%  [SYSP,SYSC] = GETLINPLANT(BLOCK,OP) Computes the open loop plant seen
%  by a Simulink block labeled BLOCK.  The plant model, SYSP, and linearized 
%  block, SYSC, returned is linearized at an operating point OP.
%
%  GETLINPLANT(BLOCK,OP,OPTIONS) Computes the open loop plant seen
%  by a Simulink block labeled BLOCK.  The linearizations are computed
%  using the options specified in OPTIONS.
%  
%  See also OPERPOINT, OPERSPEC, FINDOP, LINOPTIONS

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2007/08/20 16:43:15 $

%% Parse the input arguments
error(nargchk(2, 3, nargin, 'struct')); 

%% Get the options argument if specified
if nargin == 2
    opt = linoptions;
else
    opt = varargin{1};
end

%% Get the UDD block handle
bh = get_param(block,'Object');

%% Create the input points
for ct = length(bh.PortHandles.Outport):-1:1
    hin(ct) = linio(getfullname(bh.handle),ct,'in');
end

%% Get the source block ports
for ct = length(bh.PortHandles.Inport):-1:1
    SourceBlock = getfullname(get_param(bh.PortConnectivity(ct).SrcBlock,'Handle'));
    hout(ct) = linio(SourceBlock,bh.PortConnectivity(ct).SrcPort + 1,'out','on');
end

%% Compute the open loop plant model
sysp = linearize(op.Model,op,[hin,hout],opt);

%% Compute the controller linearization
sysc = linearize(op.Model,op,block,opt);
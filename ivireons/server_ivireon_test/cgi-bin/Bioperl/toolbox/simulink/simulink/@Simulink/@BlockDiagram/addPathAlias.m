function xout = addPathAlias(bdName, xin)
% Simulink.BlockDiagram.addPathAlias adds the path alias to the state structure
% 
% Simulink.BlockDiagram.addPathAlias adds the path alias to the state
% structure of the block diagram. The returned value has the path alias fields
% added to the given state strucutre. 
%
% Usage: 
%    xout = Simulink.BlockDiagram.getInitialState(bdName)
%    xout = Simulink.BlockDiagram.addPathAlias(bdName, xout)
%
% Inputs:
%    bdName: Name of the block diagram
%    xin:    Input state structure
%
% Outputs: 
%    xout: A state structure with the field "pathAlias" added to the state
%    signals
%
% See also Simulink documentation for details about the state structure
   
% 
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
    
    xout = sl('addPathAlias', bdName, xin);
end
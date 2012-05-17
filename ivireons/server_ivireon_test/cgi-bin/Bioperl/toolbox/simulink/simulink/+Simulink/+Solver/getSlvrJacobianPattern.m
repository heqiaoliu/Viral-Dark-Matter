function slvrJacobianPattern = getSlvrJacobianPattern(mdlH)
% Simulink.Solver.getSlvrJacobianPattern returns the solver Jacobian
% pattern present in the model
%
% Simulink.Solver.getSlvrJacobianPattern returns the solver Jacobian
% pattern  of the block diagram passed in as the input argument. 
%
% Usage: 
%   slvrJacobianPattern = Simulink.Solver.getSlvrJacobianPattern(mdl)
%
% Inputs:
%    mdl: Name or handle of a Simulink model
% 
% Outputs:
%  
%   slrJacobianPattern: is an array of Simulink.SlvrJacobianPattern objects associated with the
%                model passed in to Simulink.BlockDiagram.getSlvrJacobianPattern
%   
% Note:
%    This function will compile the model passed in if it is not currently in a 
%    compiled state,  for example, by modelName([],[],[],'compile')
%

%  Copyright 2008-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $
    
    needToThrowError = false;
    caughtError = '';
    
    try
        if(~strcmp(get_param(mdlH,'Type'),'block_diagram'))
            % error that must be a block_diagram input
            needToThrowError = true;
        end
    catch caughtError
        needToThrowError = true;
    end
    
    if(needToThrowError)   
        identifier = 'Simulink:utility:getSlvrJacobianPatternNeedsBlockDiagram';
        message = DAStudio.message(identifier);
        me = MException(identifier, '%s', message);
        if(~isempty(caughtError))
            me = addCause(me, caughtError);
        end
        throw(me);        
    end
    
    try
        slvrJacobianPattern = slprivate('slGetSlvrJacobianPattern',...
                                get_param(mdlH,'Name'));
    catch e
        identifier = 'Simulink:utility:SolverGetSlvrJacobianPatternFailed';
        message = DAStudio.message(identifier,get_param(mdlH,'Name'));
        me = MException(identifier, '%s', message);
        me = addCause(me, e);
        throw(me);        
        
    end

function sampleTimes = getSampleTimes(mdlH)
% Simulink.BlockDiagram.getSampleTimes returns the sample times present in the model
%
% Simulink.BlockDiagram.getSampleTimes returns the sample times of the block 
% diagram passed in as the input argument. 
%
% Usage: 
%   sampleTimes = Simulink.BlockDiagram.getSampleTimes(mdl)
%
% Inputs:
%    mdl: Name or handle of a Simulink model
% 
% Outputs:
%  
%   sampleTimes: is an array of Simulink.SampleTime objects associated with the
%                model passed in to Simulink.BlockDiagram.getSampleTimes
%   
% Note:
%    This function will compile the model passed in if it is not currently in a 
%    compiled state,  for example, by modelName([],[],[],'compile')
%

%  Copyright 2008-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $

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
        identifier = 'Simulink:utility:getSampleTimesNeedsBlockDiagram';
        message = DAStudio.message(identifier);
        me = MException(identifier, '%s', message);
        if(~isempty(caughtError))
            me = addCause(me, caughtError);
        end
        throw(me);        
    end

    try
        sampleTimes = slprivate('slGetSampleTimes',...
                                get_param(mdlH,'Name'));
    catch e
        identifier = 'Simulink:utility:BlockDiagramGetSampleTimesFailed';
        message = DAStudio.message(identifier,get_param(mdlH,'Name'));
        me = MException(identifier, '%s', message);
        me = addCause(me, e);
        throw(me);        
        
    end

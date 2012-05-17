function sampleTimes = getSampleTimes(blkH)
% Simulink.Block.getSampleTimes returns the sample times of the block
% passed in as the input argument. 
%
% Usage: 
%   sampleTimes = Simulink.Block.getSampleTimes(blk)
%
% Inputs:
%    blk: Full name or handle of a Simulink block
% 
% Outputs:
%  
%   sampleTimes: is an array of Simulink.SampleTime objects associated with the
%                block passed in as the input to Simulink.Block.getSampleTimes
%   
% Note:
%    This function will compile the model passed in if it is not currently in a 
%    compiled state.  for example, by using: modelName([],[],[],'compile')
%

%  Copyright 2008-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $

    needToThrowError = false;
    caughtError = '';
    
    try
        if(~strcmp(get_param(blkH,'Type'),'block'))
            % error that must be a block input
            needToThrowError = true;
        end
    catch caughtError
           needToThrowError = true;
    end
    
    if(needToThrowError)   
        identifier = 'Simulink:utility:getSampleTimesNeedsBlock';
        message = DAStudio.message(identifier);
        me = MException(identifier, '%s', message);
        if(~isempty(caughtError))
            me = addCause(me, caughtError);
        end
        throw(me);        
    end

    try
        sampleTimes = slprivate('slGetSampleTimes',blkH);
    catch e
        identifier = 'Simulink:utility:BlockGetSampleTimesFailed';
        message = DAStudio.message(identifier,getfullname(blkH));
        me = MException(identifier, '%s', message);
        me = addCause(me, e);
        throw(me);
    end
    

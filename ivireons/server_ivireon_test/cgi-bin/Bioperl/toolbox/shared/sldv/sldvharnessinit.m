function sldvharnessinit(varargin)
%SLDVHARNESSINIT - Helper utility for initializing parameters

%   Copyright 2006 The MathWorks, Inc.

% Example
%
% sldvharnessinit(3,'control_mode=1;',1,'control_mode=2');
%

    modelName = gcs;
    modelH = get_param(modelName, 'Handle');
    sigbH = sigbuild_handle(modelH);

    if ~ishandle(sigbH)
        return;
    end

    actSigbIdx = signalbuilder(sigbH,'ActiveGroup');

    allTestCnts = [varargin{1:2:end}];
    allInitCmds = {varargin{2:2:end}};

    testThreshold = cumsum(allTestCnts);
    
    if actSigbIdx<=testThreshold(1)
        origMdlIdx=1;
    else
        origMdlIdx = find(actSigbIdx>testThreshold);
        if isempty(origMdlIdx)
            return;
        end
        origMdlIdx = origMdlIdx+1;
    end

    origMdlIdx = origMdlIdx(end);

    if origMdlIdx>length(allInitCmds)
        return;
    end

    initCmd = allInitCmds{origMdlIdx};
    
    if ~isempty(initCmd)
        evalin('base',initCmd);
    end


function sigbH = sigbuild_handle(modelH)
    sigbH = find_system(modelH, ...
                        'SearchDepth',        1, ...
                        'LoadFullyIfNeeded', 'off', ...
                        'FollowLinks',       'off', ...
                        'LookUnderMasks',    'all', ...
                        'BlockType',         'SubSystem', ...
                        'PreSaveFcn',        'sigbuilder_block(''preSave'');');

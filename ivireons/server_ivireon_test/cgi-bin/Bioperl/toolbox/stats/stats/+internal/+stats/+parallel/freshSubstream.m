function substream = freshSubstream(S)
%FRESHSUBSTREAM positions S at the start of the next unused substream.
%
%   FRESHSUBSTREAM is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

    stateOnEntry = S.State;
    S.Substream = S.Substream; % this puts S at the start of the Substream
    if ~isequal(S.State,stateOnEntry)
        % S had advanced within the current Substream, so move to the next one
        S.Substream = S.Substream + 1;
    end
    substream = S.Substream;
end

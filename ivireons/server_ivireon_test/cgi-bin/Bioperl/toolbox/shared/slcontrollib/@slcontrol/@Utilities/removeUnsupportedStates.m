function state_struct = removeUnsupportedStates(this,state_struct,varargin) 
% REMOVEUNSUPPORTEDSTATES Remove any unsupported states for linearization
% and trim.  This includes non-double and bus expanded states.
%
 
% Author(s): John W. Glass 18-Oct-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:02:15 $

if nargin == 3
    if strcmp(varargin{1},'removeCONTDSTATES')
        removeCONTDSTATES = true;
    else
        removeCONTDSTATES = false;
    end
else
    removeCONTDSTATES = false;
end
    
        
% Eliminate nondouble states and bus expanded unit delays
if ~isempty(state_struct)
    for ct = length(state_struct.signals):-1:1
        if ~strcmp(class(state_struct.signals(ct).values),'double') || ...
                (~state_struct.signals(ct).inReferencedModel && ...
                (numel(get_param(state_struct.signals(ct).blockName,'RunTimeObject')) > 1))
            state_struct.signals(ct) = [];
        end

        if removeCONTDSTATES && (state_struct.signals(ct).sampleTime(1) == 0) && ...
                ~strcmp(state_struct.signals(ct).label,'CSTATE')
            state_struct.signals(ct) = [];
        end
    end
end
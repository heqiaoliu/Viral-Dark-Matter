%

%CommSplitter MPI communicator splitter.  
%   CommSplitter is for internal use only, and is subject to change without any
%   notice.  This class' constructor and destructor are collective.  Failure to
%   call either collectively will result in a non-interruptable deadlock.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/04/15 23:00:44 $

classdef CommSplitter < handle

    properties (SetAccess = private)
        OrgCommunicator
        SplitCommunicator
        Color
    end

    methods (Access = public)
        function obj = CommSplitter(color, key)
        %obj = CommSplitter(color, key) Split MPI communicators according to color and key
        %   Color and key must be integers.  Restores original communicators and deletes
        %   split communicators when object goes out of scope or is deleted.
            obj.SplitCommunicator = mpiCommManip('split', color, key);
            obj.Color = color;
            if color > 0
                obj.OrgCommunicator = mpiCommManip('select', obj.SplitCommunicator);
            end
        end

        function delete(obj)
        % Restore original communicator and delete the split communicator.
            if obj.Color > 0
                mpiCommManip('select', obj.OrgCommunicator);
                mpiCommManip('free', obj.SplitCommunicator);
            end
        end
    end
end

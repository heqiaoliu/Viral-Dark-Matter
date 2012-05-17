classdef (Hidden) sobolstate < qrandstate
    %SOBOLSTATE This undocumented class may be removed in a future release.
    
    %   SOBOLSTATE is a class that holds the state data for a Sobol
    %   sequence.  In addition to the index, this state includes the
    %   previous point in order to speed up generation of the next one.

    %   Copyright 2007-2008 The MathWorks, Inc.
    %   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:38 $

    % The point held is the uint64 version, to reduce the work required
    % in the next call to create a point
    properties
        LastPointData = [];
    end

    methods
        function ok = isComplete(obj)
            %ISCOMPLETE Check whether state is complete or partial.
            %   ISCOMPLETE(SS) returns true if the state object contains a
            %   complete set of state information.
            %
            %   Sobol states may contain an empty PointData, in which case
            %   the state is not complete
            
            ok = ~isempty(obj.LastPointData) && isComplete@qrandstate(obj);
        end


        function resetState(obj, Index)
            %RESETSTATE Change the state to a new point set index.
            %   RESETSTATE(OBJ,INDEX) changes the state to the specified
            %   point set index.  This method is used when the state of a
            %   stream is altered.
            %
            %   Sobol states clear the LastPointData property when the
            %   state is reset

            resetState@qrandstate(obj, Index);
            obj.LastPointData = [];
        end
    end
end

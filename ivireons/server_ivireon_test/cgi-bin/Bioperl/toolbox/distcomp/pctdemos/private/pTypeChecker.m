function checks = pTypeChecker()
% Return a structure with handles to functions that handle type checks
% and possibly range checks.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:08:01 $

    checks = struct('isStructWithFields', @isStructWithFields, ...
                    'isIntegerScalar', @isIntegerScalar, ...
                    'isRealScalar', @isRealScalar, ...
                    'isSchedulerObject', @isSchedulerObject, ...
                    'isJobObject', @isJobObject, ...
                    'isParallelJobObject', @isParallelJobObject);
end % End of pTypeChecker.

function valid = isStructWithFields(value, varargin)
% Verify that value is a struct and that it has the fieldnames specified  
% in varargin and only those fieldnames.
% Varargin must list at least one fieldname.
    wantedFields = varargin;
    valid = isstruct(value);
    if ~valid
        return;
    end
    actualFields = fieldnames(value);
    % Verify that the actualFields and wantedFields contain the same 
    % elements
    valid = isempty(setxor(actualFields, wantedFields));
end % End of isStructWithFields.

function valid = isIntegerScalar(value, lowerBound, upperBound)
%valid = isIntegerScalar(value) Return true if and only if value is a  
% finite, scalar integer in the specified range.
    valid = isreal(value) && isscalar(value) ...
            && (value >= lowerBound ) && (value <= upperBound) ...
            && (value  == floor(value)) && isfinite(value);
end % End of isIntegerScalar.


function valid = isRealScalar(value, lowerBound, upperBound)
%valid = isRealScalar(value) Return true if and only if value is a 
% finite, real scalar in the specified range.
    valid = isreal(value) && isscalar(value) && (value >= lowerBound) ...
            && (value <= upperBound) && isfinite(value);
end % End of isRealScalar.

function valid = isSchedulerObject(value)
%valid = isSchedulerObject(value) Return true if and only if value is a 
% single scheduler object handle.
    schedObjectTypes = {'distcomp.jobmanager', 'distcomp.lsfscheduler', ...
                        'distcomp.genericscheduler', 'distcomp.mpiexec', ...
                        'distcomp.ccsscheduler', 'distcomp.localscheduler'};
    valid = isscalar(value) && ismember(class(value), schedObjectTypes);
end

function valid = isJobObject(value)
%valid = isJobObject(value) Return true if and only if value is a 
% single job object handle.
    jobObjectTypes = {'distcomp.job', 'distcomp.simplejob'};
    valid = isscalar(value) && ismember(class(value), jobObjectTypes);
end

function valid = isParallelJobObject(value)
%valid = isParallelJobObject(value) Return true if and only if value is a 
% single parallel job object handle.
    jobObjectTypes = {'distcomp.paralleljob', 'distcomp.simpleparalleljob'};
    valid = isscalar(value) && ismember(class(value), jobObjectTypes);
end

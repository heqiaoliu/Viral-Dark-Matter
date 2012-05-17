function D = pBuildFromFcn(fcn, varargin)
; %#ok<NOSEM> % Undocumented
%pBuildFromFcn Hidden static method to build codistributed arrays using a 
%   build function.  All errors are thrown as caller.
%   
%   See also codistributed/ones, codistributed/zeros.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:51:15 $

% This error should never be triggered since this is a hidden function.
error(nargchk(1, Inf, nargin, 'struct'));

if ~isa(fcn,'function_handle')
    throwAsCaller(MException('distcomp:codistributed:codistributedFunction:functionHandleInput', ...
                             'The first input must be a function handle.'))
end

try
    [sizeVec, className, codistr] = codistributed.pParseBuildArgs(func2str(fcn), varargin); %#ok<DCUNK>
catch E
    throwAsCaller(E);
end

% TODO: We should unify error checking of the sizes.  Some of the build
% functions accept sizes as a vector, some only as multiple
% arguments.
try
    [LP, codistr] = codistr.hBuildFromFcnImpl(fcn, sizeVec, className);
catch E
    throwAsCaller(E)
end
% We have already ascertained that we are called collectively, so no further
% error checking is needed.  
D = codistributed.pDoBuildFromLocalPart(LP, codistr);  %#ok<DCUNK>

end % End of pBuildFromFcn.

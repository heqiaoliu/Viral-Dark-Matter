function D = sBuild( codBuildMethod, methodName, varargin )
;%#ok undocumented

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/05/14 16:51:32 $

% static method of distributed

% codBuildMethod is expected to be something like @codistributed.zeros; pass
% the varargin as individual arguments to spmd_feval_fcn so that we get
% correct translation from distributed->codistributed.

[argsCell, exc] = distributed.sBuildArgChk( methodName, varargin{:} ); %#ok<DCUNK>
if ~isempty( exc )
    throwAsCaller( exc );
end
D = spmd_feval_fcn( @iBuild, [{codBuildMethod}, argsCell(:).'] );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call the constructor with "noCommunication" since we guarantee we're
% collective in all arguments.
function D = iBuild( fh, varargin )
D = fh( varargin{:}, 'noCommunication' );
end

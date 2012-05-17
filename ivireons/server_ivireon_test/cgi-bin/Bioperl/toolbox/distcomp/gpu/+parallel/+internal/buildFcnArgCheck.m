function [szVecOut, clzOut, exception] = buildFcnArgCheck( buildfcn, errIdPrefix, varargin )
;%#ok undocumented

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:24:45 $

% Helper function to transform arguments to build functions such as
% ones/zeros/eye/diag/...
% buildfcn     - must be one of the known functions
% errIdPrefix  - the first part of the error ID to use
% varargin     - a list of arguments. This *must* be only a series of 
%                sizes (either a vector or multiple scalars) and an optional 
%                class name. All args will be gathered.
% Returns are:
% szVec        - resolved requested size-type args as a single vector 
%                of class double with at least 2 elements
% clz          - requested class - defaults to 'double', you should ignore this
%                for buildfcns such as true/false
% exception    - an exception describing a problem, or empty on success

% We will modify argsList as we go through, and then return it. Use this
% opportunity to ensure everything is gathered.
argsList   = cellfun( @gather, varargin, 'UniformOutput', false );

% Default values for output arguments. "exception" is unconditionally assigned
% later
szVecOut   = [1 1];
clzOut     = 'double';

% Set up properties for this build function
[classList, sizeInfo, exception] = iSetupForBuildFcn( buildfcn );
if ~isempty( exception ), return, end

% By the time we get here, argsList is a cell array of leading size-type
% arguments, and optionally a trailing classname. Deal with that first. Pass in
% the default clzOut.
[argsList, clzOut, exception] = ...
    iStripClass( buildfcn, errIdPrefix, argsList, classList, clzOut );
if ~isempty( exception ), return, end

% Check each size-type argument in isolation
[argsList, exception] = iCheckEachSizeTypeArgs( buildfcn, errIdPrefix, sizeInfo, argsList );
if ~isempty( exception ), return, end

% Check all the size-type arguments together
exception = iCheckSizeTypeArgs( buildfcn, errIdPrefix, sizeInfo, argsList );
if ~isempty( exception ), return, end

% Finally, cast the argsList into a double vector of length at least 2.
szVecOut = iCastArgsToOutputVector( argsList, szVecOut );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function szVecOut = iCastArgsToOutputVector( argsList, szVecOut )
% Recast the size-type args into a single vector. 
nargs = numel( argsList );
if nargs == 0
    % No size-type args - leave default szVecOut
elseif nargs == 1 && isscalar( argsList{ 1 } )
    % If we've only got a single size-type argument, that means a square matrix
    szVecOut = repmat( argsList{ 1 }, 1, 2 );
else
    % Multiple scalars - convert to a single vector.
    szVecOut = [ argsList{:} ];
end

% Ensure that return is "double"
szVecOut = double( szVecOut );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exception = iCheckSizeTypeArgs( buildfcn, errIdPrefix, sizeInfo, argsList )
exception = [];
numSizeTypeArgs = length( argsList );
if numSizeTypeArgs > 0
    % We've actually got some size-type arguments, so check that if we've got a
    % size-vector as the first argument, that we haven't got any other
    % size-type arguments.
    if numel( argsList{1} ) > 1
        if numSizeTypeArgs == 1
            % Ok - just one size-type argument
        else
            % Get here with: "ones([1 2], 1)"
            exception = MException( [errIdPrefix ':invalidSizeArguments'], ...
                                    ['%s arguments to "%s" must either be a single vector, or', ...
                                ' a series of scalars'], sizeInfo.Description, buildfcn );
            return;
        end
    end
end


% Finally, check that we've got an allowed number of size-type arguments
if numSizeTypeArgs < sizeInfo.Range(1) || numSizeTypeArgs > sizeInfo.Range(2)
    if sizeInfo.Range(1) == sizeInfo.Range(2)
        exception = MException( [errIdPrefix ':invalidNumberOfSizes'], ...
                                ['An invalid number (%d) of %s arguments was ', ...
                            'passed to "%s". "%s" requires %d %s arguments.'], ...
                                numSizeTypeArgs, sizeInfo.Description, buildfcn, ...
                                buildfcn, sizeInfo.Range(1), sizeInfo.Description );
    else
        exception = MException( [errIdPrefix ':invalidNumberOfSizes'], ...
                                ['An invalid number (%d) of %s arguments was ', ...
                            'passed to "%s". "%s" requires between %d and %d %s arguments.'], ...
                                numSizeTypeArgs, sizeInfo.Description, buildfcn, ...
                                buildfcn, sizeInfo.Range(1), sizeInfo.Range(2), ...
                                sizeInfo.Description );
    end
    return;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step through argsList checking each argument in (pretty much) isolation
function [argsList, exception] = ...
    iCheckEachSizeTypeArgs( buildfcn, errIdPrefix, sizeInfo, argsList )
exception = [];
if sizeInfo.AllowSingle
    checkLength = sizeInfo.MaxNDims; % the first size-type arg
else
    checkLength = 1;
end

for ii = 1:length( argsList )
    [val, E] = iCheckOneSizeTypeArg( buildfcn, errIdPrefix, sizeInfo.Description, ...
                                     argsList{ii}, 1, checkLength );
    if ~isempty( E )
        exception = E;
        return;
    else
        argsList{ii} = val;
    end
    % Make sure any subsequent arguments (if there are any) are scalars
    checkLength = 1;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the list of allowed classes, the size-type 
function [classList, sizeInfo, exception] = ...
    iSetupForBuildFcn( buildfcn )

% Lists of acceptable class arguments
floatClasses = {'double', 'single'};
intClasses32 = {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32'};
intClasses64 = {'int64', 'uint64'};
allClasses   = [floatClasses, intClasses32, intClasses64];

% Control parameters
classList              = allClasses; % empty means arg is not allowed
sizeTypeArgsRange      = [0 Inf];
sizeTypeArgDescription = 'size'; % Set this to be something else if your
                                 % size-type args aren't actually sizes
allowSingleSizeVecArg  = true;
maxNDims               = Inf; % Only for single vector arg

switch buildfcn
  case {'true', 'false', 'cell'}
    classList             = {};
  case {'ones', 'zeros'}
    % NB - ones and zeros don't explicitly doc zero-args, but it works.
    % Defaults are designed for ones/zeros
  case {'eye'}
    sizeTypeArgsRange = [0 2];
    maxNDims          = 2;
  case {'inf', 'Inf', 'nan', 'NaN', 'rand', 'randn'}
    classList             = floatClasses;
  case {'colon'}
    sizeTypeArgsRange      = [2 3];
    allowSingleSizeVecArg  = false;
    sizeTypeArgDescription = 'numeric';
    classList              = {};
  case {'randi'}
    % NOTE that you must remove the leading argument manually
    classList             = [floatClasses intClasses32];
  case {'spalloc'}
    classList              = {};
    sizeTypeArgsRange      = [3 3];
    allowSingleSizeVecArg  = false;
    sizeTypeArgDescription = 'numeric';
  case {'speye'}
    classList             = {};
    sizeTypeArgsRange     = [1 2];
    maxNDims              = 2;
  case {'sprand', 'sprandn'}
    classList              = {};
    sizeTypeArgsRange      = [3 3]; % density is "size-type".
    allowSingleSizeVecArg  = false;
    sizeTypeArgDescription = 'numeric';
  otherwise
    exception = MException( 'distcomp:buildfunction:notImplemented', ...
                            '"%s" is not implemented', buildfcn );
    return;
end

exception = [];
sizeInfo = struct( 'Range', sizeTypeArgsRange, ...
                   'Description', sizeTypeArgDescription, ...
                   'AllowSingle', allowSingleSizeVecArg, ...
                   'MaxNDims', maxNDims );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [argsList, clzOut, exception] = ...
    iStripClass( buildfcn, errIdPrefix, argsList, classList, clzOut )
exception = [];
if length( argsList ) >= 1 && ischar( argsList{end} )
    % Got a classname
    if ismember( argsList{end}, classList )
        % OK
        clzOut = argsList{end};
    else
        exception = MException( [errIdPrefix ':badClassName'], ...
                                'Unsupported output class for %s: "%s"', ...
                                buildfcn, argsList{end} );
        return;
    end
    % Strip end from argsList
    argsList(end) = [];
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val, E] = iCheckOneSizeTypeArg( buildfcn, errIdPrefix, typeDescr, val, minLen, maxLen )
szVal = size( val );
ndVal = ndims( val );
errId = [ errIdPrefix ':argCheck'];
E     = [];

% Only allow scalars or vectors
if (ndVal > 2) || ...
        (min( szVal ) ~= 1)
    E = MException( errId, ...
                    '%s arguments to "%s" must be scalars or vectors', ...
                    typeDescr, buildfcn );
    return;
end

% Is the class OK? We allow anything numeric
if isnumeric( val ) ...
        || islogical( val )
    % Ok
else
    E = MException( errId, ...
                    '%s arguments to "%s" must be numeric (not "%s")', ...
                    typeDescr, buildfcn, class( val ) );
    return;
end

% Check value attributes
if any( isnan( val ) ) || ...
        any( isinf( val ) ) || ...
        ~isreal( val )
    E = MException( errId, ...
                    '%s arguments to "%s" must real and not NaN or Inf', ...
                    typeDescr, buildfcn );
    return;
end



% Ok, it's a scalar or vector, is the length ok?
if length( val ) <= maxLen && length( val ) >= minLen
    % Ok, coerce to double
    val = double( val );
else
    E = MException( errId, ....
                    'Invalid size [%d, %d] for argument to "%s"', ...
                    szVal(1), szVal(2), buildfcn );
    return;
end
end

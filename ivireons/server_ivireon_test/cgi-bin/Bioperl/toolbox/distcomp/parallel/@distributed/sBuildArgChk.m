function [argOutCell, exception] = sBuildArgChk( buildfcn, varargin )
;%#ok undocumented

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/12/03 19:01:06 $

% static method of distributed

% We will modify argsList as we go through, and then return it.
argsList = varargin;
exception = []; % Return an exception if necessary
argOutCell = []; % Only filled out if successful

% Lists of acceptable class arguments
floatClasses = {'double', 'single'};
intClasses32 = {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32'};
intClasses64 = {'int64', 'uint64'};
allClasses   = [floatClasses, intClasses32, intClasses64];

% Control parameters
classList              = allClasses; % empty means arg is not allowed
                                     
minSizeTypeArgs        = 0;
maxSizeTypeArgs        = Inf;
sizeTypeArgDescription = 'size'; % Set this to be something else if your
                                 % size-type args aren't actually sizes
allowSingleSizeVecArg  = true;
maxNDims               = Inf; % Only for single vector arg

firstSizeArg = 1;
lastSizeArg  = length( argsList );

switch buildfcn
  case {'true', 'false', 'cell'}
    classList             = {};
  case {'ones', 'zeros'}
    % NB - ones and zeros don't explicitly doc zero-args, but it works. 
    % Defaults are designed for ones/zeros
  case {'eye'}
    maxSizeTypeArgs       = 2;
    maxNDims              = 2;
  case {'inf', 'Inf', 'nan', 'NaN', 'rand', 'randn'}
    classList             = floatClasses;
  case {'colon'}
    minSizeTypeArgs       = 2;
    maxSizeTypeArgs       = 3;
    allowSingleSizeVecArg = false;
    sizeTypeArgDescription = 'numeric';
  case {'randi'}
    % Special case - remove first arg and check separately, let other args flow through
    if nargin < 2
        exception = MException( 'distcomp:buildfunction:NargChck', ...
                                'At least 1 input argument required' );
        return;
    end
    [val, E]              = iCheckSizeTypeArg( buildfcn, 'numeric', argsList{1}, 1, 2 );
    if ~isempty( E )
        throwAsCaller( E );
    else
        argsList{1}       = val;
    end
    firstSizeArg          = 2;
    classList             = [floatClasses intClasses32];
    % Rest of defaults work OK here.
  case {'spalloc'}
    classList             = {};
    maxSizeTypeArgs       = 3;
    minSizeTypeArgs       = 3;
    allowSingleSizeVecArg = false;
    sizeTypeArgDescription = 'numeric';
  case {'speye'}
    classList             = {};
    minSizeTypeArgs       = 1;
    maxSizeTypeArgs       = 2;
    maxNDims              = 2;
  case {'sprand', 'sprandn'}
    classList             = {};
    minSizeTypeArgs       = 3; % density is "size-type".
    maxSizeTypeArgs       = 3;
    allowSingleSizeVecArg = false;
    sizeTypeArgDescription = 'numeric';
  otherwise
    exception = MException( 'distcomp:buildfunction:notImplemented', ...
                            '"%s" is not implemented', buildfcn );
    return;
end

% By the time we get here, argsList is a cell array of leading size-type
% arguments, and optionally a trailing classname. Deal with that first.
if length( argsList ) >= 1 && ischar( argsList{end} )
    % Got a classname
    if ismember( argsList{end}, classList )
        % OK
    else
        exception = MException( 'distcomp:buildfunction:badClassName', ...
                                'Unsupported output class for %s: "%s"', ...
                                buildfcn, argsList{end} );
        return;
    end
    lastSizeArg = length( argsList ) - 1;
end


if allowSingleSizeVecArg
    checkLength = maxNDims; % the first size-type arg
else
    checkLength = 1;
end
for ii = firstSizeArg : lastSizeArg
    [val, E] = iCheckSizeTypeArg( buildfcn, sizeTypeArgDescription, argsList{ii}, 1, checkLength );
    if ~isempty( E )
        exception = E;
        return;
    else
        argsList{ii} = val;
    end
    checkLength = 1;
end

numSizeTypeArgs = 1 + (lastSizeArg - firstSizeArg);
if firstSizeArg <= lastSizeArg
    % We've actually got some size-type arguments, so check that if we've got a
    % size-vector as the first argument, that we haven't got any other
    % size-type arguments.
    if numel( argsList{firstSizeArg} ) > 1
        if numSizeTypeArgs == 1
            % Ok - just one size-type argument
        else
            exception = MException( 'distcomp:buildfunction:invalidSizeArguments', ...
                                    ['%s arguments to "%s" must either be a single vector, or', ...
                                ' a series of scalars'], sizeTypeArgDescription, buildfcn );
            return;
        end
    end
end


% Finally, check that we've got an allowed number of size-type arguments
if numSizeTypeArgs < minSizeTypeArgs || numSizeTypeArgs > maxSizeTypeArgs
    if minSizeTypeArgs == maxSizeTypeArgs
        exception = MException( 'distcomp:buildfunction:invalidNumberOfSizes', ...
                                ['An invalid number (%d) of %s arguments was ', ...
                            'passed to "%s". "%s" requires %d %s arguments.'], ...
                                numSizeTypeArgs, sizeTypeArgDescription, buildfcn, ...
                                buildfcn, minSizeTypeArgs, sizeTypeArgDescription );
    else
        exception = MException( 'distcomp:buildfunction:invalidNumberOfSizes', ...
                                ['An invalid number (%d) of %s arguments was ', ...
                            'passed to "%s". "%s" requires between %d and %d %s arguments.'], ...
                                numSizeTypeArgs, sizeTypeArgDescription, buildfcn, ...
                                buildfcn, minSizeTypeArgs, maxSizeTypeArgs, ...
                                sizeTypeArgDescription );
    end
    return;
end

% Return the modified argsList.
argOutCell = argsList;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [val, E] = iCheckSizeTypeArg( buildfcn, typeDescr, val, minLen, maxLen )
szVal = size( val );
ndVal = ndims( val );
errId = ['distcomp:' buildfcn ':argCheck'];
E     = [];

% Only allow scalars or vectors
if (ndVal > 2) || ...
        (min( szVal ) ~= 1)
    E = MException( errId, ...
                    '%s arguments to "%s" must be scalars or vectors', ...
                    typeDescr, buildfcn );
    return;
end

% Is the class OK? We allow anything numeric, plus distributed/codistributed.
if isnumeric( val ) ...
        || islogical( val ) ...
        || isa( val, 'distributed' ) 
    
    % Don't gather distributeds - they'll get gathered on the labs.
    % XXX FIXME: temp workaround, gather distributeds for now - workaround since
    % codistributed constructors don't like codistributed arguments, and
    % also codistributors need to be superiorto codistributed.
    if isa( val, 'distributed' )
        warning( 'distcomp:distributedBuild:GatheringDistributed', ...
                 'gathering a distributed for build' );
        val = gather( val );
    end

    % Ok
else
    E = MException( errId, ...
                    '%s arguments to "%s" must be either numeric or distributed (not "%s")', ...
                    typeDescr, buildfcn, class( val ) );
    return;
end

% Ok, it's a scalar or vector, is the length ok?
if length( val ) <= maxLen && length( val ) >= minLen
    % Ok
else
    E = MException( errId, ....
                    'Invalid size [%d, %d] for argument to "%s"', ...
                    szVal(1), szVal(2), buildfcn );
    return;
end
end

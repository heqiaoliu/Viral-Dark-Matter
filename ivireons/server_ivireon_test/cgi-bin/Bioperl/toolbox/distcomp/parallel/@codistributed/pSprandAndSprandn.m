function D = pSprandAndSprandn(buildFcn, fcnName, m, n, density, varargin)
%pSprandAndSprandn  A private function that implements sprand and sprandn support


% buildFcn is either @sprand or @sprandn, fcnName is the corresponding string.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/29 08:23:39 $

% Argument parsing.  The options are:
% buildFcn(m, n, density)
% buildFcn(m, n, density [, codistr] [, 'noCommunication'])
% where buildFcn is either sprand or sprandn.

[codistr, allowCommunication] = iParseOptionalArgs(fcnName, varargin{:});
if ~allowCommunication
    distributedutil.CodistParser.verifyNotCodistWithNoComm(fcnName, ...
                                                      {m, n, density});
end
    
m = distributedutil.CodistParser.gatherIfCodistributed(m);
n = distributedutil.CodistParser.gatherIfCodistributed(n);
density = distributedutil.CodistParser.gatherIfCodistributed(density);

iVerifyDensity(fcnName, density);
% Use the error checking in CodistParser to check the input sizes.  We already
% have the sizes as m and n, so we don't need the output arguments.
distributedutil.CodistParser.parseArraySizes({m, n});

if allowCommunication
    argsToCheck = {[m, n, density], codistr};
    distributedutil.CodistParser.verifyReplicatedInputArgs(fcnName, argsToCheck);
end

codistr.hVerifySupportsSparse();

% Map the construction of the sprand/sprandn array into the other build functions.  
% Class name is empty and will therefore not be provided to the build function.
className = '';
% Function handle that can build local part.  Accepts matrix size as input.
buildFcnForLocalPart = @(sz1, sz2) buildFcn(sz1, sz2, density);
[LP, codistr] = codistr.hBuildFromFcnImpl(buildFcnForLocalPart, [m, n], className);

% We have already ascertained that we are called collectively, so no further
% error checking is needed.  
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.
    
end % End of spalloc.

function iVerifyDensity(fcnName, density)

if ~isscalar(density) || ~isnumeric(density) || density < 0 || density > 1
    error(sprintf('distcomp:codistributed:%s:InvalidDensity', fcnName), ...
          'Density must be a scalar between 0 and 1.')
end

end % End of iVerifyDensity.

function [codistr, allowCommunication] = iParseOptionalArgs(fcnName, varargin)
argList = varargin;
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

% If argList is not empty at this point, the argument parsing failed.
if ~isempty(argList)
    error(sprintf('distcomp:codistributed:%s:InvalidOptionalInputs', fcnName), ...
          ['Invalid optional input arguments to %s.  Expected ' ...
               'a codistributor object and/or the string ''noCommunication''.'], ...
          upper(fcnName));
end

end % End of iParseOptionalArgs.

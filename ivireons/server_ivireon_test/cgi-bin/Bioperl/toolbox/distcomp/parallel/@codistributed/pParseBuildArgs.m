function [sizeVec, className, codistr, allowCommunication] = pParseBuildArgs(fcnName, argList)
; %#ok<NOSEM> % Undocumented
%pParseBuildArgs Parse input arguments to codistributed build functions
%   This is the generalization of all of the "build" function argument parsing:
%   ones, zeros, cell, true, false, nan, inf, eye.
%   
%   Expected input: pParseArgs(szs [, className] [,codistr] [,'noCommunication'])
%   where szs is either a comma separated list of sizes, or a vector of sizes.    
%   
%   sizeVec is returned as a vector of length >= 2 containing integer-valued scalars.
%   className is either the empty string, or the specified value


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:51:17 $

if ~ischar(fcnName) || ~iscell(argList)
    error('distcomp:codistributed:pParseBuildArgs:InvalidInput', ...
          'Invalid input arguments.');
end

[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);
if allowCommunication
    % Ensure that we can handle class name being codistributed.
    argList = distributedutil.CodistParser.gatherElements(argList);
else
    distributedutil.CodistParser.verifyNotCodistWithNoComm(fcnName, argList);    
end

if length(argList) >= 1 && ischar(argList{end}); 
    className = argList{end};
    sizesD = argList(1:end - 1);
else
    className = '';
    sizesD = argList;
end

sizeVec = distributedutil.CodistParser.parseArraySizes(sizesD);

if allowCommunication
    argsToCheck = {sizeVec, className, codistr};
    distributedutil.CodistParser.verifyReplicatedInputArgs(fcnName, argsToCheck);
end

end % End of pParseBuildArgs.

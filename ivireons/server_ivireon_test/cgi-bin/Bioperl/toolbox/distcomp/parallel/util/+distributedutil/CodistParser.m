%CodistParser Collection of utility functions to help with argument parsing in
%codistributed and codistributors.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $   $Date: 2010/05/03 16:06:16 $

classdef CodistParser

    methods ( Access = public, Static )
        function [argList, allowCommunication] = extractCommFlag(argList)
        %[argList, allowCommunication] = extractCommFlag(argList) Finds 
        %and removes the optional flag 'noCommunication' from the end of argList.
        %allowCommunication defaults to true.
            allowCommunication = true;
            if isempty(argList)
                return;
            end
            if iIsCommFlag(argList{end})
                argList(end) = [];
                allowCommunication = false;
            end
        end    

        function [argList, codistr] = extractCodistributor(argList)
        %[argList, allowCommunication] = extractCodistributor(argList) Finds 
        %and removes an optional codistributor from the end of argList.  
        %The codistributor defaults to codistributor().
            if isempty(argList)
                codistr = codistributor();
                return;
            end
            if isa(argList{end}, 'AbstractCodistributor')
                codistr = argList{end};
                argList(end) = [];
            else
                codistr = codistributor();
            end
            % There should not be any codistributors remaining in the argument list.
            if any(cellfun(@(x) isa(x, 'AbstractCodistributor'), argList))
                error('distcomp:codistributed:BuildArgs:BadCodistributorPosition', ...
                      ['When provided, codistributor must either be the last ' ...
                       'argument, or the second to last argument, followed by ' ...
                       '''noCommunication''.']);
            end
        end
        
        function verifyNotCodistWithNoComm(fcnName, argList)
        %verifyNotCodistWithNoComm(fcnName, argList)
        % Call this function if the 'noCommunication' flag has been set to
        % verify that other input arguments are not codistributed and
        % need to be gathered.  Throws an error if any of the elements
        % in the argList cell array are of class codistributed.
            if any(cellfun(@(x) isa(x, 'codistributed'), argList))
                ID = sprintf('distcomp:codistributed:%s:CodistrNotAllowed',...
                             fcnName);
                error(ID, ['Input arguments to %s must not be codistributed when '...
                           '''noCommunication'' is specified.'], ...
                      distributedutil.CodistParser.fcnNameToUpper(fcnName));
            end
        end
        
        function val = gatherIfCodistributed(val)
            if isa(val, 'codistributed')
                val = gather(val);
            end
        end

        function val = gatherElements(cellArr)
        % Gather all codistributed elements in the input cell array
            val = cellfun(@distributedutil.CodistParser.gatherIfCodistributed, ...
                          cellArr, 'UniformOutput', false);
        end

        function tf = isValidLabindex(labidx)
        % tf = isValidLabindex(labidx) returns true if and only if labidx is a valid lab
        % index.
            allowZero = false;
            tf = isscalar(labidx) ...
                 && isPositiveIntegerValuedNumeric(labidx, allowZero) ...
                 && labidx <= numlabs;
        end

        function sizesvec = parseArraySizes(sizesD)
        % sizesD is given as a cell array of sizes.  
        % Output is a non-empty vector of sizes.
    
        % Error check inputs and extract a cell array sizesD of the size inputs
            sizesD = cellfun(@distributedutil.CodistParser.gatherIfCodistributed, ...
                             sizesD, 'UniformOutput', false);
            if isempty(sizesD)
                % Like most of the build functions, we create a scalar if the size is
                % omitted.  
                sizesvec = [1 1];
                return;
            elseif length(sizesD) == 1
                % row vector of sizes, including a single scalar
                if ~isvector(sizesD{1}) || size(sizesD{1},1)~=1
                    error('distcomp:codistributed:BuildArgs:rowVectorSizes', ...
                          'Size inputs must be a numeric row vector.');
                end
                if isscalar(sizesD{1})
                    sizesD = [sizesD sizesD];
                end
            else
                % (more than 1) individual scalar sizes
                if ~all(cellfun(@isscalar,sizesD)) || ~all(cellfun(@isnumeric,sizesD))
                    error('distcomp:codistributed:BuildArgs:scalarSizes', ...
                          'Size inputs must be numeric scalars.');
                end
            end
            sizesvec = [sizesD{:}];
            
            if ~isPositiveIntegerValuedNumeric(sizesvec, true)
                error('distcomp:codistributed:BuildArgs:badSizesInput', ...
                      'Size inputs must be non-negative and integer-valued.');
            end
            
        end % End of parseArraySizes.

        function [m, n, codistr, allowCommunication] = parseCodistributorSparse(argList)
        % Parse the arguments to AbstractCodistributor.sparse. 
            [argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
            [argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);
            if ~allowCommunication
                distributedutil.CodistParser.verifyNotCodistWithNoComm('sparse', argList);
            end

            if length(argList) ~= 2
                error('distcomp:codistributor:sparse', ...
                      ['Invalid input arguments to SPARSE.  The first two argument must be the ' ...
                       'matrix sizes, followed by the codistributor, and the optional ' ...
                       '''noCommunication'' flag.']);
            end

            sizeVec = distributedutil.CodistParser.parseArraySizes(argList);
            m = sizeVec(1);
            n = sizeVec(2);

        end % End of parseCodistributorSparse.

        function verifyReplicatedInputArgs(fcnName, argList)
        % Verify that all input arguments are replicated, and throws an error
        % if they are not.  fcnName is the function name for the
        % message identifier and error message.
            if ~isreplicated([{fcnName}, argList])
                ID = sprintf('distcomp:codistributed:%s:NonReplicated', fcnName);
                error(ID, 'Input arguments to %s must be the same on all labs.', ...
                      distributedutil.CodistParser.fcnNameToUpper(fcnName));
            end
        end % End of verifyReplicatedInputArgs. 

        function fcnName = fcnNameToUpper(fcnName)
        % Converts a lower case function name to upper case.  Leaves a mixed
        % case function name unmodified.
            if strcmp(lower(fcnName), fcnName)
                % All in lower case, so display in upper case.
                fcnName = upper(fcnName);
            end
        end % End of fcnNameToUpper.
        
        function verifyDiagIntegerScalar(fcnName, diag)
        %verifyDiagIntegerScalar(fcnName, diag)
        % Call this function to check that specified diagonal
        % input argument is valid (integer scalar).  Called in
        % diag, tril, triu.
            if ~( isnumeric(diag) && isscalar(diag) && ...
                  isfinite(diag) && (round(diag) == diag) && isreal(diag) )
                % Error message is identical to the one in base MATLAB.
                ID = sprintf('distcomp:codistributed:%s:kthDiagInputNotInteger', ...
                             fcnName);
                error(ID, 'K-th diagonal input to %s must be an integer scalar.', ...
                      distributedutil.CodistParser.fcnNameToUpper(fcnName));
            end
        end % End of verifyDiagIntegerScalar
    end
end


function tf = iIsCommFlag(flag)
    tf = ischar(flag) && strcmp(flag, 'noCommunication');
end

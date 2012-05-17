function D = colon(a, varargin)
%CODISTRIBUTED.COLON Build codistributed arrays of the form A:D:B
%   CODISTRIBUTED.COLON returns a codistributed vector equivalent to the return 
%   vector of the COLON function or the colon notation. 
%   
%   D = CODISTRIBUTED.COLON(A,B) is the same as CODISTRIBUTED.COLON(A,1,B).
%   
%   D = CODISTRIBUTED.COLON(A,D,B) is a codistributed vector storing the values
%   A:D:B.
%   
%   Other optional arguments to CODISTRIBUTED.COLON must be specified after
%   B, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Example:
%   spmd
%       N = 1000;
%       d = codistributed.colon(1,N)
%   end
%   
%   distributes the vector 1:N over the labs.
%   
%   See also COLON, CODISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:00 $

error(nargchk(2, 5, nargin, 'struct'));

try
    [a, d, b, codistr, allowCommunication] = iParseArgs(a, varargin{:});
    if allowCommunication
        % Don't display CODISTRIBUTED.COLON to users because they might arrive here
        % via the colon overloads on codistributor1d and 2dbc.
        distributedutil.CodistParser.verifyReplicatedInputArgs('colon', ...
                                                          {a, d, b, codistr});
    end
catch e
    throw(e);
end

[LP, codistr] = codistr.hColonImpl(a, d, b);
% We have already verified that a, d, and b are called collectively, so no
% further error checking is necessary.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.

end % End of codistributed.colon.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a, d, b, codistr, allowCommunication] = iParseArgs(a, varargin)
% iParseArgs Input should be input arguments 2 to end of the input arguments to
% codistributed.colon.

% First, identify all uses of 'noCommunication' and specifications of
% codistributors at the end of the argument list.
argList = varargin;
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

if isempty(argList)
    error('distcomp:codistributed:colon:NoEndpoint', ...
          'Upper limit of COLON range is missing.'); 
end

% The only remaining options are:
% {b}
% {d, b}
switch length(argList)
  case 1
    % argList must be {b}.
    d = 1;
    b = argList{1};
  case 2
    % argList must be {d, b} 
    d = argList{1};
    b = argList{2};
  otherwise
    % argList{3} and up were invalid.
    error('distcomp:codistributed:colon:InvalidArgs', ...
          ['Invalid input arguments to COLON.  ', ...
           'When provided, the last arguments must be a codistributor ' ...
           'or the flag ''noCommunication''.']);
end
if ~allowCommunication
    distributedutil.CodistParser.verifyNotCodistWithNoComm('colon', ...
                                                      {a, b, d});
end

a = distributedutil.CodistParser.gatherIfCodistributed(a);
b = distributedutil.CodistParser.gatherIfCodistributed(b);
d = distributedutil.CodistParser.gatherIfCodistributed(d);

% Verify the values of a, d and b.  We make more stringent requirements than the
% built-in colon as we only support integer and float scalars.  This leaves out
% all the oddifies with chars, char arrays, vectors, and complex values.
isValidNumericLike = @(x) isinteger(x) || isfloat(x);
if isValidNumericLike(a)  ...
        && isValidNumericLike(b) ...
        && isValidNumericLike(d)
    a = a(1);
    b = b(1);
    d = d(1);
else
    error('distcomp:codistributed:colon:InvalidStartEnd', ...
          ['Invalid input arguments to COLON.  ', ...
           'Start, end and stride must be double, single or integer.']);
end

end % End of iParseArgs.

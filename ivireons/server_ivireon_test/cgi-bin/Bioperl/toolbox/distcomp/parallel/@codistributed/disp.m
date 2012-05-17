function disp(D)
%DISP Display codistributed array
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       disp(D);
%   end
%   
%   See also DISP, CODISTRIBUTED, CODISTRIBUTED/DISPLAY.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:41 $

codistr = getCodistributor(D);
LP = getLocalPart(D);
varName = inputname(1);
maxStrLen = 1000;
% TODO: This API does not handle multi-page display.
[header, matrix] = codistr.hDispImpl(LP, varName, maxStrLen);

if ~isempty(matrix)
    fprintf('%s\n', matrix);
end

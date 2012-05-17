function display(D)
%DISPLAY Display codistributed array
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       display(D);
%   end
%   
%   See also DISPLAY, CODISTRIBUTED, CODISTRIBUTED/DISP.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:42 $

% By overloading display, we can control how the variable name appears in the
% output.  We want it to appear as
%   varname( < some indexing expression > ) = 
% followed by the local part of the codistributed array.    

codistr = getCodistributor(D);
LP = getLocalPart(D);
varName = inputname(1);
maxStrLen = 1000;
% TODO: This API does not handle paging correctly.
[header, matrix] = codistr.hDispImpl(LP, varName, maxStrLen);


if isequal(get(0,'FormatSpacing'),'compact')
    sep = '';
else
    sep = sprintf('\n');
end
%if ~isempty(matrix)
    fprintf('%s%s\n%s%s', sep, header, sep, matrix);
    %end

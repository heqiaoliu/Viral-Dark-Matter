function D = cell2mat(D)
%CELL2MAT Convert the contents of a codistributed cell array into a single matrix
%   M = CELL2MAT(C)
%   
%   Example:
%   spmd
%       N = 1000;
%       c = codistributed(num2cell(1:N))
%       m = cell2mat(c)
%       classc = classUnderlying(c)
%       classm = classUnderlying(m)
%   end
%   
%   takes the 1-by-N codistributed cell array c and returns the
%   codistributed double row vector m equal to codistributed.colon(1, N).
%   classc is 'cell' while classm is 'double'.
%   
%   See also CELL2MAT, CODISTRIBUTED, CODISTRIBUTED/COLON, 
%   CODISTRIBUTED/CELL, CODISTRIBUTED/CLASSUNDERLYING.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/08/29 08:23:34 $

if isempty(D)
    % cell2mat converts all empties into a 0-by-0 double array.
    D = codistributed.zeros(0, 0, 'noCommunication');
    return;
end

LP = getLocalPart(D);
codistr = getCodistributor(D);
clear D;

if ~codistr.hCell2MatCheck(LP)
    % We know that codistributor1d supports cell2mat.
    [LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, ...
                                                      codistributor1d());
end

[LP, codistr] = codistr.hCell2MatImpl(LP);
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.

end % End of cell2mat.

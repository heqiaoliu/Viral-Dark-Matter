function dlabgrid = defaultLabGrid()
%codistributor2dbc.defaultLabGrid    MATLAB's choice for computational grid
%   dlabgrid = codistributor2dbc.defaultLabGrid()
%            = [nprow, npcol]
%   Express numlabs as nprow*npcol with integers nprow <= npcol.
%   nprow is the greatest integer <= sqrt(numlabs) for which
%   npcol = numlabs/nprow is also an integer.
%   If numlabs is a perfect square, then nprow = npcol = sqrt(numlabs).
%   If numlabs is a prime, then nprow = 1, npcol = numlabs.
%   If numlabs is an even power of 2, then nprow = npcol = sqrt(numlabs).
%   If numlabs is an odd power of 2, then nprow = npcol/2 = sqrt(numlabs/2).
%
%   Example:
%     spmd
%         codistr = codistributor2dbc()
%     end
%   returns a distribution scheme with codistr.LabGrid set to
%   codistributor2dbc.defaultLabGrid 
%
%   See also codistributor2dbc, codistributor2dbc/defaultBlockSize,
%   codistributor2dbc/defaultOrientation

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.6.1 $  $Date: 2010/06/07 13:33:23 $

nprow = floor(sqrt(numlabs));
npcol = numlabs/nprow;
while npcol ~= round(npcol)
   nprow = nprow - 1;
   npcol = numlabs/nprow;
end
dlabgrid = [nprow npcol];

end % End of defaultLabGrid.

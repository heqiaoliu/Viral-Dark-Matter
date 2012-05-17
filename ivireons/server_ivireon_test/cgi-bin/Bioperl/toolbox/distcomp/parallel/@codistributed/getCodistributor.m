function dist = getCodistributor(D)
%getCodistributor returns codistributor of a codistributed array
%   DIST = getCodistributor(D) is an object with the distribution information
%   of the codistributed array D.
%   
%   See also CODISTRIBUTOR, CODISTRIBUTOR1D, CODISTRIBUTOR2DBC, 
%   CODISTRIBUTED/GETLOCALPART.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:02 $

dist = D.Codistributor;

function updateTables(h,m) 
%updateTables   Update GF tables. 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/05 01:58:27 $

[GF_TABLE1 GF_TABLE2] = populateTables(h, m);
h.PrivGfTable1 = GF_TABLE1;
h.PrivGfTable2 = GF_TABLE2;
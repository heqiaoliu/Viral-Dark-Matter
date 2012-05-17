function Hd2 = todf1sos(Hd);
%TODF1SOS  Convert to direct-form 1 sos.
%   Hd2 = TODF1SOS(Hd) converts discrete-time filter Hd to direct-form 1
%   sos filter Hd2. 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/16 18:52:19 $
  

Hd2 = dfilt.df1sos(Hd.sosMatrix,Hd.ScaleValues);


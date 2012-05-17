function Hd2 = todf1tsos(Hd);
%TODF1TSOS  Convert to direct-form 1 transposed sos.
%   Hd2 = TODF1TSOS(Hd) converts discrete-time filter Hd to direct-form 1
%   transposed sos filter Hd2. 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/16 18:52:20 $
  

Hd2 = dfilt.df1tsos(Hd.sosMatrix,Hd.ScaleValues);


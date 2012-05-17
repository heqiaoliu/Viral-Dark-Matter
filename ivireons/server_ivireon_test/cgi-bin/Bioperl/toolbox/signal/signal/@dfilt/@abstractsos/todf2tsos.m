function Hd2 = todf2tsos(Hd);
%TODF2TSOS  Convert to direct-form II transposed sos.
%   Hd2 = TODF2TSOS(Hd) converts discrete-time filter Hd to direct-form II
%   transposedd sos filter Hd2. 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/16 18:52:21 $
  

Hd2 = dfilt.df2tsos(Hd.sosMatrix,Hd.ScaleValues);


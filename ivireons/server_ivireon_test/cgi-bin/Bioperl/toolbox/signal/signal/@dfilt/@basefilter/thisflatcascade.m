function Hflat = thisflatcascade(this,Hflat)
%THISFLATCASCADE Add singleton to the flat list of filters Hflat 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:26:11 $

Hflat = [Hflat;this];
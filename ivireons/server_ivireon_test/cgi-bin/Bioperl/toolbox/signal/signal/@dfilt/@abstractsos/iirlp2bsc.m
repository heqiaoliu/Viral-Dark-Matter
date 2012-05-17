function [Ht,anum,aden] = iirlp2bsc(Hd, varargin)
%IIRLP2BSC IIR Lowpass to complex bandstop transformation

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:17:12 $

[Ht,anum,aden] = ciirxform(Hd, @zpklp2bsc, varargin{:});


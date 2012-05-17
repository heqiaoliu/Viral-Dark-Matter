function [Ht,anum,aden] = iirlp2bpc(Hd, varargin)
%IIRLP2BPC IIR Lowpass to complex bandpass transformation

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:17:10 $

[Ht,anum,aden] = ciirxform(Hd, @zpklp2bpc, varargin{:});

function [Ht,anum,aden] = iirbpc2bpc(Hd, varargin)
%IIRBPC2BPC IIR complex bandpass to complex bandpass transformation

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:17:08 $

[Ht,anum,aden] = ciirxform(Hd, @zpkbpc2bpc, varargin{:});


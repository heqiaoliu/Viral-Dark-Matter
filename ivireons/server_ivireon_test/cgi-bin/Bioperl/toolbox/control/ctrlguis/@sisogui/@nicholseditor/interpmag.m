function Magi = interpmag(Editor, W, Mag, Wi)
%INTERPMAG  Interpolates magnitude data in the visual units.
%           MAG and MAGI are expressed in Absolute units.
%           The interpolation occurs in abs or log scale depending
%           on the magnitude scale and units.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2007/06/07 14:36:47 $

% Interpolate log of magnitude
Magi = pow2(utInterp1(W, log2(Mag), Wi));

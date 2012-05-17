function h = realizemdltarget
%REALIZEMDLTARGET Constructor of the realizemdltarget class.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:49:55 $

h = dspfwiztargets.realizemdltarget;
h.blockname = 'Filter';
h.OptimizeZeros = 'on';
h.OptimizeOnes = 'on';
h.OptimizeNegOnes = 'on';
h.OptimizeDelayChains = 'on';


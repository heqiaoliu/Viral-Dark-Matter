function wf = allwaves(this)
%ALLWAVES  Collects all @waveform components.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:43 $
wf = [this.Responses;this.Input];


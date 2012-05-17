function centerdc(this,state)
%CENTERDC   Shift the zero-frequency component to the center of the spectrum.
%   CENTERDC(H) or CENTERDC(H,true) shifts the data and the frequency
%   values in the DSP data (<a href="matlab:help dspdata">dspdata</a>) object H, so that DC is in the center
%   of the spectrum.
%
%   Note that if the object H contains data for half the Nyquist range,
%   it's first converted to occupy the whole Nyquist range, before the DC
%   component is centered.  This causes the number of points to roughly
%   double, since the spectrum now occupies the whole Nyquist interval.
%
%   CENTERDC(H,false) shifts the data and the frequency values in the data
%   object H, so that DC is in the left edge of the spectrum.  
%
%   NOTE: H must be constructed with the correct setting of 'CenterDC'
%   that represents the data. If CenterDC is set to a value that is
%   inconsistent with the data and frequency, then the command above will
%   have no effect.
%
%   See also DSPDATA, SPECTRUM.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:35:04 $

% Help for the CENTERDC method.

% [EOF]

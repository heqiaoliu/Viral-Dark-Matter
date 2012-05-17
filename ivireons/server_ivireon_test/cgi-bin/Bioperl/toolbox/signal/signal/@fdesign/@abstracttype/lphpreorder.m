function lphpreorder(this,Hd)
%LPHPREORDER   Rule-of-thumb lowpass/highpass reordering of SOS.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 16:55:53 $

% Reference: D. Schlichtharle. Digital Filters. Basic and Design.
% Springer-Verlag. Berlin, 2000.

reorder(Hd,'down');

nsecs = nsections(Hd);

% Get reorder indices for lowpass/highpass rule-of-thumb
reorderindx = lphpreorderindx(this,Hd,nsecs);

reorder(Hd,reorderindx);



% [EOF]

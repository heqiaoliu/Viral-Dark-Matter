function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN Design the filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:05:00 $

hd=fdesign.sqrtrcosine;
hd.Specification = 'N,Beta';

b = rcosmindesign(this, hspecs, 'sqrt', hd);

% [EOF]

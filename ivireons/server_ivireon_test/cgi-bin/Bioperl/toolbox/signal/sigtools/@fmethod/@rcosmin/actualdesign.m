function b = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN Design the filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/31 07:04:49 $

hd=fdesign.rcosine;
hd.Specification = 'N,Beta';

b = rcosmindesign(this, hspecs, 'normal', hd);

% [EOF]

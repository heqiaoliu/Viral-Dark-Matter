function timercb(varargin)
%TIMERCB Wrapper for timer object M-file callback.
%
%   See also TIMER
%

%    Copyright 2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/10/27 23:53:50 $

%Create a timer object out of the JavaTimer, and then call the object
%timercb.
h = handle(varargin{1});
t = timer(h);
timercb(t, varargin{2:end});


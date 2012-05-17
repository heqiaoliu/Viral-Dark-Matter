function dates = tsdateinterval(startdate, varargin)
%TSDATEINTERVAL Generate a uniformly spaced sequence of dates/times.
%   TSDATEINTERVAL('START','END') creates a cell array of strings
%   representing a sequence of dates and times starting at 'START' and
%   ending at 'END' separated by a one day interval.
%   
%   TSDATEINTERVAL('START','END','UNITINTERVAL') spaces the time/date
%   sequence by the unit defined in the 'UNITINTERVAL' string
%
%   TSDATEINTERVAL('START',LENGTH,'UNITINTERVAL') creates a sequence
%   starting at 'START' with spacing defined by the 'UNITINTERVAL' string
%   with the specified length
%
%   See also TSUNITCONV, TSISDATEFORMAT
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/15 22:55:15 $

if ischar(varargin{1})
   if nargin==3
        dates = cellstr(datestr(datenum(startdate):tsunitconv('days',varargin{2}):datenum(varargin{1})));
   else
        dates = cellstr(datestr(datenum(startdate):datenum(varargin{1})));
   end
else
        dates = cellstr(datestr(tsunitconv('days',varargin{2})* ...
            (0:(varargin{1}-1))+datenum(startdate)));
end
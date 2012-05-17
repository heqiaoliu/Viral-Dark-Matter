function ts = setinterpmethod(ts,varargin)
%SETINTERPMETHOD  Set default interpolation method in a time series.
%
%   TS = SETINTERPMETHOD(TS,METHOD), where METHOD is a string, sets the default
%   interpolation method, METHOD, in TS. METHOD can be either 'linear' or
%   'zoh' (zero-order hold). For example: 
%       ts = timeseries(rand(100,1),1:100);
%       ts = setinterpmethod(ts,'zoh')
%
%   TS = SETINTERPMETHOD(TS,FHANDLE), where FHANDLE is a function handle, sets
%   the interpolation method in TS to a special interpolation method
%   defined in the function handle FHANDLE.  For examle:
%       ts = timeseries(rand(100,1),1:100);
%       myFuncHandle = @(new_Time,Time,Data) interp1(Time,Data,new_Time,'linear','extrap');
%       ts = setinterpmethod(ts,myFuncHandle);
%       ts = resample(ts,[-5:0.1:10]);
%       plot(ts);
%   Note: for FHANDLE, (1) the number of input arguments must be three; (2)
%   the order of input arguments must be new_Time, Time, and Data; (3) the
%   single output argument must be the interpolated data only. 
%
%   TS = SETINTERPMETHOD(TS,INTERPOBJ), where INTERPOBJ is a
%   tsdata.interpolation object, directly replaces the interpolation object
%   stored in time series TS. For example:
%       ts = timeseries(rand(100,1),1:100);
%       myFuncHandle = @(new_Time,Time,Data) interp1(Time,Data,new_Time,'linear','extrap');
%       myInterpObj = tsdata.interpolation(myFuncHandle);
%       ts = setinterpmethod(ts,myInterpObj);
%
%   See also TIMESERIES/GETINTERPMETHOD, TIMESERIES/TIMESERIES

%   Copyright 2005-2010 The MathWorks, Inc.

error(nargchk(2,3,nargin));
if numel(ts)~=1
    error('timeseries:setinterpmethod:noarray',...
     'The setinterpmethod method can only be used for a single timeseries object');
end
if ischar(varargin{1})
    ts.DataInfo.interpolation.fhandle = {@tsinterp varargin{1}}; 
    ts.DataInfo.interpolation.Name = varargin{1};
elseif isa(varargin{1},'function_handle')
    ts.DataInfo.interpolation.fhandle = {varargin{1}}; %#ok<CCAT1>
    if nargin==3 && ~isempty(varargin{2})
        ts.DataInfo.interpolation.Name = varargin{2};
    else
        ts.DataInfo.interpolation.Name = 'myFuncHandle';
    end
elseif isa(varargin{1},'tsdata.interpolation')
    ts.DataInfo.interpolation = varargin{1};
else
    error('timeseries:setinterpmethod:invInterp',...
        'The interpolation method must be specified as either a string or a function handle.');
end

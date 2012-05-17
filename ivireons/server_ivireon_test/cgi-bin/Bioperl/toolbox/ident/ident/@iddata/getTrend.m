function Tr = getTrend(Z,Type)
%GETTREND Create a trend information object for data.
%   Tr = getTrend(Z)
%   Create a TrendInfo object Tr with default values. Tr is an object with
%   properties DataName, InputOffset, OutputOffset, InputSlope and
%   OutputSlope. For more information, type "help idutils.TrendInfo".
%   This call is equivalent to doing:
%       [N,ny,nu,nexp] = size(Z);
%       Tr = idutils.TrendInfo(nu,ny,nexp);
%
%   The values of the properties representing I/O offsets and slopes are all
%   zeros, with sizes matching the dimensions (nu, ny, nexp) of the data Z. 
%
%   Tr = getTrend(Z,Type)
%   creates the TrendInfo object Tr whose properties are populated
%   according to the type of information requested:
%   Type = []: returns Tr with default values for input and output slopes
%              and offsets. This is the default.
%   Type = 0:  returns Tr with Tr.InputOffset set to input data mean and
%              Tr.OutputOffset set to output data mean.
%   Type = 1:  returns Tr with its properties configured to represent the
%              best straight-line fits to input and output data of Z. The
%              straight line is represented by the equation:
%                   ULine = Tr.InputOffset + (time-t0)*Tr.InputSlope
%              for input data, where time = Z.SamplingInstants and t0 is
%              the first time value (start time).
%              (similar equation for output data)
%
%   Usage:
%   Use this function to conveniently create a TrendInfo object. 
%   1. If you need to remove non-zero signal offsets from transient data,
%      create Tr with Type = [] and fill in the offset values manually.
%      Then call DETREND function to remove those offsets from data. See
%      help on DETREND function for more information.
%   2. If you need to remove signal means (or linear trends) while keeping
%      track of removed values, you may directly call DETREND with 2 output
%      arguments. 
%      Alternatively, you may do:  
%      Tr = getTrend(Z,0); %extract mean data; use 1 for linear trend
%      Zd = detrend(Z,Tr);
%   3. If you want to add (superimpose) a trend to a given data, create a
%      TrendInfo object and use the RETREND function:
%      Tr = getTrend(Z); or, getTrend(Z,[]);
%      % set offset and slope values
%      Tr.InputOffset = u0; 
%      etc... 
%      % apply the configured TrendInfo object to data:
%      Znew = retrend(Z,Tr);
%
%   See also DETREND, RETREND, idutils.TrendInfo.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/12/29 02:07:24 $

if nargin<2
    Type = [];
end

if ~(isempty(Type) || any(Type==[0 1]))
    ctrlMsgUtils.error('Ident:iddata:getTrendCheck1');
end

[N,ny,nu,nexp] = size(Z);

if isempty(Type)
    Tr = idutils.TrendInfo(nu,ny,nexp);
elseif Type==0
    [dum,Tr] = detrend(Z,0);
else
    % linear trend
    if strcmpi(Z.Domain,'frequency')
        ctrlMsgUtils.error('Ident:iddata:getTrendCheck2');
    end
    [dum,Tr] = detrend(Z,1);
end
Tr.DataName = inputname(1);

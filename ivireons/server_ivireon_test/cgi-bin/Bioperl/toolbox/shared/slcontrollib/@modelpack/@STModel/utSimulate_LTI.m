function [y,t] = utSimulate_LTI(this,sys,T,InputType,InputSignals)
% UTSIMULATE_LTI method to simulate an LTI object that is derived
% from a SISOTOOL model object
%
% Input:
%   sys          - an LTI object
%   T            - a TimeSpan vector
%   InputType    - one of {'step'|'impulse'|'specified'}
%   InputSignals - timeseries of inputs to use when input type is specified
%

% Method was private but made public to facilitate unit testing

% Author(s): A. Stothert 02-Aug-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/09/21 00:07:03 $

Ts       = sys.Ts;
T        = T(:);                %Make sure specified times are in a column
T        = T(T>=0);             %Can only simulate positive time

%Determine simulation stop time
if ~isfinite(T(end))
   %Infinite stop time specified, choose time twice last finite value.
   if numel(T) > 1
      T(end) = 2*max(T(isfinite(T)));
   else
      %No end time to base Tend on, choose zero as this will ensure we
      %only simulate step/impulse without a specified end time, i.e., end
      %time left to timegrid.m
      T(end) = 0;
   end
end
Tend = T(end);

if Ts > 0
   %Discrete system, make sure end time is multiple of Ts
   Tend = Tend-rem(Tend,Ts)+Ts;
end

%Perform simulation
if any(strcmp(InputType,{'step','impulse'}))
   %Setp or impulse simulation required
   if strcmp(InputType,'step')
      simFcn = @step;
   else
      simFcn = @impulse;
   end
   [y,t] = simFcn(sys);  %Simulate to some finite end time
   if t(end) < Tend
      %Default simulation stopped before requested end time, redo
      %simulation with specified end time
      [yInf,tInf] = simFcn(sys,Tend);
      %Combine the two responses
      [t,idx] = unique([t;tInf]);
      Y = [y;yInf];
      y = Y(idx,:);
   end
elseif strcmp(InputType,'specified')
   %Simulation with specified input signal required
   if isempty(InputSignals) || ...
         ~(isa(InputSignals,'timeseries') || ...
         isa(InputSignals,'tscollection'))
      ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','InputSignals','timeseries')
   end
   t = InputSignals.Time;
   u = localGetTSData(InputSignals);
   y = lsim(sys,u,t);
   %Filter out any requested time points that are beyond the input signal
   %time range
   T = T(T<=max(t));
else
   %Unknown simulation input type
   t = []; y = [];
end

if any(isnan(y))
   %Output giving nan for unstable system, replace nans with largest
   %absolute value in signal
   y(isnan(y)) = max(abs(y(isfinite(y))));
end

%Make sure produce output for all requested times
nT = numel(T);    %Number of specified time points
if nT > 1
   %Use interpolation to find outputs at specified times
   if Ts > 0
      %Discrete system, use zoh
      yAdd = nan(nT-1,size(y,2));
      for ct=1:nT
         idx  = find(t<=T(ct),1,'last');
         yAdd(ct,:) = y(idx,:);
      end
   else
      %Continuous system, use linear interpolation
      yAdd = interp1(t,y,T,'linear');
   end
   %Combine interpolated points with original response
   t = [t; T];
   y = [y; yAdd];
   [t,idx] = unique(t); %Also sorts t
   y = y(idx,:);
end
end

function data = localGetTSData(ts_collection)
%Helper function to return all the data from a ts collection in a matrix
%format

if isa(ts_collection,'tscollection')
   %Multiple inputs
   Names = gettimeseriesnames(ts_collection);
   for ct=1:numel(Names)
      data = [data, ts_collection.(Names{ct}).data];
   end
elseif isa(ts_collection,'timeseries')
   %Single input
   data = ts_collection.data;
else
   data = [];
end
end

function isstab = localISStable(sys)

CanComputeStab = true;
if isa(sys,'ss')
   %Be careful of systems with internal delays
   iod = getIODelay(getPrivateData(sys));
   if any(isnan(iod(:)))
      CanComputeStab = false;
   end
end

if CanComputeStab
   isstab = isstable(sys);
else
   isstab = false; %Can not tell is system is stable, assume not. Forces extra time points
end
end
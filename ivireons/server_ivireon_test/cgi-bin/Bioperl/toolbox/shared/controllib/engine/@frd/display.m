function display(sys)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%   Author(s): S. Almy
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:36:01 $
CWS = get(0,'CommandWindowSize');      % max number of char. per line
LineMax = round(.8*CWS(1));
Inames = sys.InputName;
Onames = sys.OutputName;
StaticFlag = isstatic(sys);
Data = sys.Data_;
FreqUnits = sys.FrequencyUnit;

% Get system name
SysName = sys.Name_;
if isempty(SysName),
   SysName = inputname(1);
end
if isempty(SysName),
   SysName = 'ans';
end

% Get number of models in array
[Ny,Nu] = iosize(sys);
ArraySizes = size(Data);
nsys = numel(Data);
if nsys>1,
   % Construct sequence of indexing coordinates
   indices = zeros(nsys,length(ArraySizes));
   for k=1:length(ArraySizes),
      range = 1:ArraySizes(k);
      base = repmat(range,[prod(ArraySizes(1:k-1)) 1]);
      indices(:,k) = repmat(base(:),[nsys/numel(base) 1]);
   end
end

% Handle various cases
if Ny==0 || Nu==0 || any(ArraySizes==0) || isempty(sys.Frequency)
   fprintf('Empty frequency response model.\n')
   
elseif nsys==1
   % Single model
   dispsys(Data,Inames,Onames,LineMax,'',FreqUnits)
   % Sampling time
   dispTs(sys,StaticFlag);
   % Metadata
   dispGroup(sys);
  
   if Data.Ts==0
      disp(xlate('Continuous-time frequency response.'));
   else
      disp(xlate('Discrete-time frequency response.'));
   end
else
   % FRD array
   Marker = '=';
   for k=1:nsys,
      coord = sprintf('%d,',indices(k,:));
      Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
      fprintf('\n%s\n',Model)
      disp(Marker(1,ones(1,length(Model))))      
      dispsys(Data(k),Inames,Onames,LineMax,'  ',FreqUnits)
   end
   
   % Display LTI properties (I/O groups and sample time)
   dispTs(sys,StaticFlag);
   dispGroup(sys);
   
   % Last line
   ArrayDims = sprintf('%dx',ArraySizes);
   if StaticFlag,
      fprintf('%s array of static gains.\n',ArrayDims(1:end-1))
   elseif Data(1).Ts==0,
      fprintf('%s array of continuous-time frequency responses.\n',...
         ArrayDims(1:end-1))
   else
      fprintf('%s array of discrete-time frequency responses.\n',...
         ArrayDims(1:end-1))
   end
      
end

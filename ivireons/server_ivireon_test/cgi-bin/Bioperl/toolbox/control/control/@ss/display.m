function display(sys)
%DISPLAY   Pretty-print for SS models.

%   Author(s): A. Potvin, P. Gahinet, 4-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.25.4.6 $  $Date: 2010/02/08 22:28:29 $

% Extract state-space data and sampling/delay times
Data = sys.Data_;
Inames = sys.InputName;
Onames = sys.OutputName;

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

% Use ISSTATIC to account for delays
StaticFlag = isstatic(sys);

% Handle various types
if any(ArraySizes==0) || ((Ny==0 || Nu==0) && StaticFlag)
   fprintf('Empty state-space model.\n')
   
elseif nsys==1,
   % Single SS model
   dispsys(Data,Inames,Onames,'')
   % Sampling time
   dispTs(sys,StaticFlag);
   % Metadata
   dispGroup(sys);
   % Last line
   if StaticFlag,
      disp(xlate('Static gain.'))
   elseif Data.Ts==0,
      disp(xlate('Continuous-time model.'))
   else
      disp(xlate('Discrete-time model.'));
   end
   
else
   % SS array
   Marker = '=';
   for k=1:nsys,
      coord = sprintf('%d,',indices(k,:));
      Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
      fprintf('\n%s\n',Model)
      disp(Marker(1,ones(1,length(Model))))
      dispsys(Data(k),Inames,Onames,'  ')
   end
   
   % Display LTI properties (I/O groups and sample times)
   disp(' ')
   dispTs(sys,StaticFlag);
   dispGroup(sys);
   
   % Last line
   ArrayDims = sprintf('%dx',ArraySizes);
   if StaticFlag,
      fprintf('%s array of static gains.\n',ArrayDims(1:end-1))
   elseif Data(1).Ts==0,
      fprintf('%s array of continuous-time state-space models.\n',...
         ArrayDims(1:end-1))
   else
      fprintf('%s array of discrete-time state-space models.\n',...
         ArrayDims(1:end-1))
   end
   
end

function display(sys)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.24.4.8 $  $Date: 2010/02/08 22:29:10 $
CWS = get(0,'CommandWindowSize');      % max number of char. per line
LineMax = round(.8*CWS(1));
Inames = sys.InputName;
Onames = sys.OutputName;
StaticFlag = isstatic(sys);
Data = sys.Data_;

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
if Ny==0 || Nu==0 || any(ArraySizes==0)
   fprintf('Empty transfer function.\n')
   
elseif nsys==1
   % Single TF model
   dispsys(Data,Inames,Onames,LineMax,'',sys.Variable)
   % Sampling time
   dispTs(sys,StaticFlag);
   % Metadata
   dispGroup(sys);
  
else
   % TF array
   Marker = '=';
   for k=1:nsys,
      coord = sprintf('%d,',indices(k,:));
      Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
      fprintf('\n%s\n',Model)
      disp(Marker(1,ones(1,length(Model))))
      dispsys(Data(k),Inames,Onames,LineMax,'  ',sys.Variable);
   end
   
   % Display LTI properties (I/O groups and sample time)
   disp(' ')
   dispTs(sys,StaticFlag);
   dispGroup(sys);
   
   % Last line
   ArrayDims = sprintf('%dx',ArraySizes);
   if StaticFlag,
      fprintf('%s array of static gains.\n',ArrayDims(1:end-1))
   elseif Data(1).Ts==0,
      fprintf('%s array of continuous-time transfer functions.\n',ArrayDims(1:end-1))
   else
      fprintf('%s array of discrete-time transfer functions.\n',ArrayDims(1:end-1))
   end
   
end

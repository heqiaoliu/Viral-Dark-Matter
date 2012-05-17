function display(sys,varargin)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.29.4.10 $  $Date: 2010/02/08 22:29:25 $

%*******************************************************************************
% Default display type is roots (r). Other options are time constant (t)
% and frequency (f) 
if nargin>=2
    dispType = varargin{1}; %keep for backward compatibility
else
    dispType = sys.DisplayFormat;
end
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

% Convert variable z to w if we are using the t or f plot types
Variable = sys.Variable;
if any(strcmp(Variable,{'z','q'})) && any(dispType(1)=='tf')
   dispVar = 'w';
else
   dispVar = Variable;
end

% Handle various cases
if Ny==0 || Nu==0 || any(ArraySizes==0)
    fprintf('Empty zero-pole-gain model.\n')
    
elseif nsys==1
    % Single ZPK model    
    dispsys(Data,Inames,Onames,LineMax,'',dispVar,dispType,Variable)
    
    % Display definition of w if it is used as a surrogate for 'z' 
    % (i.e., when DisplayFormat is 't' or 'f')
    if strcmpi(dispVar,'w')
        if Data.Ts>0
            fprintf('with w = (%s-1)/Ts\n',Variable)
        else
            fprintf('with w = (%s-1)\n',Variable)
        end
        disp(' ');
    end
    
   % Sampling time
   dispTs(sys,StaticFlag);
   % Metadata
   dispGroup(sys);
    
 else
    % ZPK array
    Marker = '=';
    Ts = Data(1).Ts;
    for k=1:nsys,
       coord = sprintf('%d,',indices(k,:));
       Model = sprintf('Model %s(:,:,%s)',SysName,coord(1:end-1));
       fprintf('\n%s\n',Model)
       disp(Marker(1,ones(1,length(Model))))
       dispsys(Data(k),Inames,Onames,LineMax,'  ',dispVar,dispType)
    end
    
    % Display definition of w if it is used as a surrogate for 'z'
    if strcmpi(dispVar,'w')
        if Ts>0
            fprintf('with w = (%s-1)/Ts\n',Variable)
        else
            fprintf('with w = (%s-1)\n',Variable)
        end
        disp(' ');
    end
    
    % Display LTI properties (I/O groups and sample time)
    disp(' ')
    dispTs(sys,StaticFlag);
    dispGroup(sys);
    
    % Last line
    ArrayDims = sprintf('%dx',ArraySizes);
    if StaticFlag,
       fprintf('%s array of static gains.\n',ArrayDims(1:end-1))
    elseif Ts==0,
       fprintf('%s array of continuous-time zero-pole-gain models.\n',...
          ArrayDims(1:end-1))
    else
       fprintf('%s array of discrete-time zero-pole-gain models.\n',...
          ArrayDims(1:end-1))
    end
    
 end

function xsim = linsimstate(Type,varargin)
%LINSIMSTATE  Builds extended initial condition for linear simulations.
%
%   LINSIMSTATE builds a default initial condition for linear simulations 
%   assuming that all delayed signals have zero value prior to the 
%   simulation start.
%
%   XSIM = LINSIMSTATE('ss',X0,DIN,DOUT,DF) constructs an initial 
%   condition XSIM given
%     * The initial state X0
%     * The vectors DIN, DOUT, and DF of input, output, and 
%       internal delays.
%   You can use XSIM as initial condition for SSSIM.
%
%   XSIM = LINSIMSTATE('tf',NUM,DEN,DIO) constructs an initial  
%   condition XSIM given 
%     * The cell arrays NUM and DEN of numerator and denominator
%       coefficients
%     * The matrix DIO of total I/O delay for each I/O pair.
%   You can use XSIM as initial condition for TFSIM.
%
%   XSIM = LINSIMSTATE('zpk',Z,P,IODELAY) constructs an initial  
%   condition XSIM given 
%     * The cell arrays Z and P of poles and zeros for each
%       I/O transfer function
%     * The matrix IODELAY of total I/O delay for each I/O pair.
%   You can use XSIM as initial condition for ZPKSIM.
%
%   See also SSSIM, TFSIM, ZPKSIM, TOTALDELAY.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:47:37 $
ni = length(varargin);
switch lower(Type)
   case 'ss'
      if ni<4,
         ctrlMsgUtils.error('Controllib:utility:linsimstate1','ss')
      else
         x0 = varargin{1};
         Din = varargin{2};
         Dout = varargin{3};
         Df = varargin{4};
      end
      xsim = struct(...
         'State',x0,...
         'Input',{LocalMakeBuffers(Din)},...
         'Output',{LocalMakeBuffers(Dout)},...
         'Internal',{LocalMakeBuffers(Df)});
      
   case 'tf'
      if ni<3,
         ctrlMsgUtils.error('Controllib:utility:linsimstate2','tf')
      else
         num = varargin{1};
         den = varargin{2};
         Dio = varargin{3};
      end
      [ny,nu] = size(Dio);
      % Check for improper models
      for ct=1:ny*nu
         if den{ct}(1)==0
            ctrlMsgUtils.error('Controllib:general:NotSupportedSimulationImproperSys')
         end
      end
      orders = cellfun('length',den)-1;
      xsim = struct('Input',cell(nu,1),'Output',{cell(ny,1)});
      for j=1:nu
         xsim(j).Input = zeros(max(orders(:,j)+Dio(:,j)),1);
         for i=1:ny
            xsim(j).Output{i} = zeros(orders(i,j),1);
         end
      end
      
   case 'zpk'
      if ni<3,
         ctrlMsgUtils.error('Controllib:utility:linsimstate2','zpk')
      else
         z = varargin{1};
         p = varargin{2};
         Dio = varargin{3};
      end
      [ny,nu] = size(Dio);
      orders = cellfun('length',p);
      % Check for improper models
      no = cellfun('length',z);
      if any(no(:)>orders(:))
          ctrlMsgUtils.error('Controllib:general:NotSupportedSimulationImproperSys')
      end
      xsim = struct('Input',cell(nu,1),'Output',{cell(ny,1)});
      for j=1:nu
         xsim(j).Input = zeros(max(orders(:,j)+Dio(:,j)),1);
         for i=1:ny
            xsim(j).Output{i} = zeros(orders(i,j),1);
         end
      end
      
end
      
      
function buf = LocalMakeBuffers(DelayVector)
% Construct buffers to store delayed inputs, outputs, or internal variables
nd = length(DelayVector);
buf = cell(nd,1);
for ct=1:nd
   buf{ct} = zeros(DelayVector(ct),1);
end

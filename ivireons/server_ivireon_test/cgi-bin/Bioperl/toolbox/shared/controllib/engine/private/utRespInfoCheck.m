function [y,t,yfinal,SettlingTimeThreshold,RiseTimeLims,Ts] = ...
   utRespInfoCheck(y,varargin)
% Checks inputs to STEPINFO and LSIMINFO.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:11:15 $

% Default options
RiseTimeLims = [0.1 0.9];
SettlingTimeThreshold = 0.02;
Ts = 0;  % continuous-time data

% Parse extra inputs
narg = length(varargin);
UserDefinedT = false;
UserDefinedYf = false;
ct = 1;
while ct<=narg
   arg = varargin{ct};
   if isstruct(arg)
      % Quick option passing (no validity checks)
      RiseTimeLims = arg.RiseTimeLimits;
      SettlingTimeThreshold = arg.SettlingTimeThreshold;
      Ts = arg.Ts;
      ct = ct+1;
   elseif ischar(arg)
      % Name/Value pair
      if ct==narg
          ctrlMsgUtils.error('Controllib:general:CompleteOptionsValuePairs2');
      else
         switch lower(arg(1))
            case 's'
               try
                  SettlingTimeThreshold = double(varargin{ct+1});
               catch
                   ctrlMsgUtils.error('Controllib:plots:RespInfoCheck1');
               end
               if ~isscalar(SettlingTimeThreshold) || SettlingTimeThreshold<0 || SettlingTimeThreshold>1
                   ctrlMsgUtils.error('Controllib:plots:RespInfoCheck1');
               end
            case 'r'
               try
                  RiseTimeLims = double(varargin{ct+1});
               catch
                   ctrlMsgUtils.error('Controllib:plots:RespInfoCheck2');
               end
               if numel(RiseTimeLims)~=2 || any(RiseTimeLims<0 | RiseTimeLims>1)
                   ctrlMsgUtils.error('Controllib:plots:RespInfoCheck2');
               elseif RiseTimeLims(1)>RiseTimeLims(2)
                   ctrlMsgUtils.error('Controllib:plots:RespInfoCheck2');
               end
            case 't'
               % Undoc
               Ts = varargin{ct+1};
         end
      end
      ct = ct+2;
   else
      if UserDefinedT
         try
            yfinal = double(arg);
         catch
             ctrlMsgUtils.error('Controllib:plots:RespInfoCheck3','YFINAL');
         end
         UserDefinedYf = true;
      else
         try
            t = double(arg(:));
         catch
             ctrlMsgUtils.error('Controllib:plots:RespInfoCheck3','T');
         end
         UserDefinedT = true;
      end
      ct = ct+1;
   end
end

% Y Data
if ndims(y)>3
    ctrlMsgUtils.error('Controllib:plots:RespInfoCheck4');
elseif isvector(y)
   y = y(:);
end
sy = [size(y) 1];
ns = sy(1);
ny = sy(2);  
nu = sy(3);
   
% Time vector
if ~UserDefinedT
   t = (1:ns)';
elseif length(t)~=ns
    ctrlMsgUtils.error('Controllib:plots:RespInfoCheck5','Y','T');
elseif ns==0
    ctrlMsgUtils.error('Controllib:plots:RespInfoCheck6');
end

% Final value
if ~UserDefinedYf
   yfinal = reshape(y(ns,:,:),ny,nu);
elseif isscalar(yfinal) && (ny~=1 || nu~=1)
   yfinal = repmat(yfinal,ny,nu);
elseif numel(yfinal)~=ny*nu
    ctrlMsgUtils.error('Controllib:plots:RespInfoCheck5','Y','YFINAL');
else
   yfinal = reshape(yfinal,ny,nu);
end

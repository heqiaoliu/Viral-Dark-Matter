function [a,b,c,d,e,Ts,Td] = dssdata(sys,varargin)
%DSSDATA  Quick access to descriptor state-space data.
%
%   [A,B,C,D,E] = DSSDATA(SYS) returns the A,B,C,D,E matrices for the 
%   descriptor state-space model SYS (see DSS). DSSDATA is equivalent to 
%   SSDATA for explicit state-space models (E=I). If SYS has internal 
%   delays, A,B,C,D,E are obtained by first setting all internal delays 
%   to zero (delay-free dynamics).
%
%   [A,B,C,D,E,TS] = DSSDATA(SYS) also returns the sampling time TS.
%   Other properties of SYS can be accessed using struct-like dot syntax 
%   (for example, SYS.InputName).
%
%   Support for arrays of state-space models:
%
%   [A,B,C,D,E,TS] = DSSDATA(SYS,J1,...,JN) extracts the data for the
%   (J1,...,JN) entry in the model array SYS.
%
%   If all models in SYS have the same order, DSSDATA returns 
%   multi-dimensional arrays A,B,C,D,E where A(:,:,k), B(:,:,k), C(:,:,k), 
%   D(:,:,k), E(:,:,k) are the state-space matrices of the k-th model 
%   SYS(:,:,k).
%
%   If the models in SYS have variable order, use the syntax
%      [A,B,C,D,E] = DSSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate cells in 
%   the cell arrays A,B,C,D,E.
%
%   See also DSS, ISPROPER, SSDATA, GETDELAYMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:37 $
ni = nargin-1;
s = size(sys);
nd = length(s);

% Detect 'cell' flag
cflag = (ni==1 && strncmpi(varargin,'c',1));

% Get data
try
   if cflag || (nd>2 && ni==0)
      % Cell or ND outputs
      ArraySize = [s(3:end) 1 1];
      % Extract data in cell arrays
      a = cell(ArraySize);
      b = cell(ArraySize);
      c = cell(ArraySize);
      d = cell(ArraySize);
      e = cell(ArraySize);
      nsys = numel(a);
      if nsys==0
         Ts = 0;
      else
         for ct=1:nsys
            [a{ct},b{ct},c{ct},d{ct},e{ct},Ts] = dssdata_(sys,ct);
         end
      end
      % Handle request for ND array output
      if ~cflag
         % Requesting ND arrays
         if nsys==0
            nx = 0; 
         else
            nx = cellfun(@length,a);
            if ~all(nx(:)==nx(1))
               ctrlMsgUtils.error('Control:ltiobject:ssdata2','dssdata')
            end
            nx = nx(1);
         end
         a = reshape(cat(3,a{:}),[nx nx ArraySize]);
         b = reshape(cat(3,b{:}),[nx s(2) ArraySize]);
         c = reshape(cat(3,c{:}),[s(1) nx ArraySize]);
         d = reshape(cat(3,d{:}),s);
         e = reshape(cat(3,e{:}),[nx nx ArraySize]);
      end
   else
      % Matrix outputs
      [a,b,c,d,e,Ts] = dssdata_(sys,varargin{:});
   end
catch ME
   ltipack.throw(ME,'command','dssdata',class(sys))
end

% Obsolete TD output
if nargout>6,
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxTD')
   Td = (sys.InputDelay)';
end

function [a,b,c,d,Ts,Td] = ssdata(sys,varargin)
%SSDATA  Quick access to state-space data.
%
%   [A,B,C,D] = SSDATA(SYS) returns the A,B,C,D matrices of the state-space
%   model SYS.  If SYS is not a state-space model, it is first converted to 
%   the state-space representation. If SYS is in descriptor form (nonempty 
%   E matrix), an equivalent explicit form is first derived. If SYS has 
%   internal delays, A,B,C,D are obtained by first setting all internal 
%   delays to zero (delay-free dynamics).
%
%   [A,B,C,D,TS] = SSDATA(SYS) also returns the sampling time TS. Other 
%   properties of SYS can be accessed using struct-like dot syntax (for
%   example, SYS.StateName).
%
%   Support for arrays of state-space models:
%
%   [A,B,C,D,TS] = SSDATA(SYS,J1,...,JN) extracts the data for the 
%   (J1,...,JN) entry in the model array SYS.
%
%   If all models in SYS have the same order, SSDATA returns
%   multi-dimensional arrays A,B,C,D where A(:,:,k), B(:,:,k), C(:,:,k), 
%   D(:,:,k) are the state-space matrices of the k-th model SYS(:,:,k).
%
%   If the models in SYS have variable order, use the syntax
%      [A,B,C,D] = SSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate cells in
%   the cell arrays A,B,C,D.
%
%   See also SS, DSSDATA, GETDELAYMODEL, TFDATA, ZPKDATA.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:37:05 $
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
      % Get A,B,C,D data in cell arrays
      % Note: Because of possible descriptor->explicit reductions, the
      %       size of A is not known a priori
      a = cell(ArraySize);
      b = cell(ArraySize);
      c = cell(ArraySize);
      d = cell(ArraySize);
      nsys = numel(a);
      if nsys==0
         Ts = 0;
      else
         for ct=1:nsys
            [a{ct},b{ct},c{ct},d{ct},Ts] = ssdata_(sys,ct);
         end
      end
      % Handle request for ND array output
      if ~cflag
         if nsys==0
            nx = 0;
         else
            nx = cellfun(@length,a);
            if ~all(nx(:)==nx(1))
               ctrlMsgUtils.error('Control:ltiobject:ssdata2','ssdata')
            end
            nx = nx(1);
         end
         a = reshape(cat(3,a{:}),[nx nx ArraySize]);
         b = reshape(cat(3,b{:}),[nx s(2) ArraySize]);
         c = reshape(cat(3,c{:}),[s(1) nx ArraySize]);
         d = reshape(cat(3,d{:}),s);
      end
   else
      % Matrix outputs
      [a,b,c,d,Ts] = ssdata_(sys,varargin{:});
   end
catch ME
   ltipack.throw(ME,'command','ssdata',class(sys))
end

% Obsolete TD output
if nargout>5,
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxTD')
   Td = (sys.InputDelay)';
end

function [z,p,k,Ts,Td] = zpkdata(sys,varargin)
%ZPKDATA  Quick access to zero-pole-gain data.
%
%   [Z,P,K] = ZPKDATA(SYS) returns the zeros, poles, and gain for each 
%   I/O channel of the dynamic system SYS. The cell arrays Z,P and the 
%   matrix K have as many rows as outputs and as many columns as inputs, 
%   and their (I,J) entries specify the zeros, poles, and gain of the 
%   transfer function from input J to output I. SYS is first converted to 
%   zero-pole-gain format if necessary.
%
%   [Z,P,K,TS] = ZPKDATA(SYS)  also returns the sampling time TS. Other 
%   properties of SYS can be accessed using struct-like dot syntax (for
%   example, SYS.Variable).
%
%   For a single SISO model SYS, the syntax
%       [Z,P,K] = ZPKDATA(SYS,'v')
%   returns the zeros Z and poles P as column vectors rather than 
%   cell arrays.       
%
%   When SYS is an array of dynamic systems, Z,P,K are arrays of the same 
%   size as SYS where Z(:,:,m), P(:,:,m), K(:,:,m) give the ZPK data of 
%   SYS(:,:,m).
%
%   [Z,P,K,TS] = ZPKDATA(SYS,J1,...,JN) extracts the data for the 
%   (J1,...,JN) entry in the model array SYS.
%
%   See also ZPK, TFDATA, SSDATA.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/03/31 18:37:17 $
s = size(sys);
nd = length(s);

% Detect 'v' flag
vflag = find(strncmpi(varargin,'v',1));
varargin(:,vflag) = [];
ni = length(varargin);

% Get data
try
   if nd>2 && ni==0
      % Data for multiple models
      z = cell(s);  p = cell(s);  k = zeros(s);
      nsys = prod(s(3:end));
      if nsys==0
         Ts = 0;
      else
         for ct=1:nsys
            [z(:,:,ct),p(:,:,ct),k(:,:,ct),Ts] = zpkdata_(sys,ct);
         end
      end
   else
      % Data for single model
      [z,p,k,Ts] = zpkdata_(sys,varargin{:});
   end
catch ME
   ltipack.throw(ME,'command','zpkdata',class(sys))
end

% Return vectors if requested
if ~isempty(vflag) && isscalar(z)
   % Convenience syntax for SISO case
   z = z{1};  p = p{1};
end

% Obsolete TD output
if nargout>4,
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxTD')
   Td = (sys.InputDelay)';
end

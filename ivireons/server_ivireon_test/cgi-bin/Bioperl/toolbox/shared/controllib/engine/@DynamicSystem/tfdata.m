function [num,den,Ts,Td] = tfdata(sys,varargin)
%TFDATA  Quick access to transfer function data.
%
%   [NUM,DEN] = TFDATA(SYS) returns the numerator(s) and denominator(s) 
%   of the transfer function SYS. For a transfer function with NY outputs 
%   and NU inputs, NUM and DEN are NY-by-NU cell arrays where the (I,J) 
%   entry specifies the transfer function from input J to output I. 
%   SYS is first converted to transfer function if necessary.
%
%   [NUM,DEN,TS] = TFDATA(SYS) also returns the sampling time TS. Other
%   properties of SYS can be accessed using struct-like dot syntax (for
%   example, SYS.ioDelay).
%
%   For a single SISO model SYS, the syntax
%       [NUM,DEN] = TFDATA(SYS,'v')
%   returns the numerator and denominator as row vectors rather than
%   cell arrays.
%
%   [NUM,DEN,TS] = TFDATA(SYS,J1,...,JN) extracts the data for the 
%   (J1,...,JN) entry in the model array SYS.
%
%   See also TF, ZPKDATA, SSDATA.

%   Author(s): P. Gahinet, 25-3-96
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/03/31 18:37:10 $
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
      num = cell(s);  den = cell(s);
      nsys = prod(s(3:end));
      if nsys==0
         Ts = 0;
      else
         for ct=1:nsys
            [num(:,:,ct),den(:,:,ct),Ts] = tfdata_(sys,ct);
         end
      end
   else
      % Data for single model
      [num,den,Ts] = tfdata_(sys,varargin{:});
   end
catch ME
   ltipack.throw(ME,'command','tfdata',class(sys))
end
   
% Return vectors if requested
if ~isempty(vflag) && isscalar(num)
   % Convenience syntax for SISO case
   num = num{1};
   den = den{1};
end

% Obsolete TD output
if nargout>3,
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxTD')
   Td = (sys.InputDelay)';
end


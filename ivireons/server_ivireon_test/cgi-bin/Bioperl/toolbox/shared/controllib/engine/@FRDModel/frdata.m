function [resp,freq,Ts,Td] = frdata(sys,varargin)
%FRDATA  Quick access to frequency response data.
%
%   [RESPONSE,FREQ] = FRDATA(SYS) returns the response data and
%   frequency samples of the frequency response data (FRD) model SYS.
%
%   For a single model SYS with Ny outputs, Nu inputs, and Nw frequency
%   points, FREQ is the column vector of frequency points, and RESPONSE 
%   is a Ny-by-Nu-by-Nw array where the (I,J,K) element specifies the 
%   response from input J to output I at the K-th frequency point FREQ(K).  
%
%   [RESPONSE,FREQ,TS] = FRDATA(SYS) also returns the sample time TS.  Other
%   properties of SYS can be accessed using struct-like dot syntax (for
%   example, SYS.FrequencyUnit).
%
%   For SISO models, the syntax
%       [RESPONSE,FREQ] = FRDATA(SYS,'v')
%   returns RESPONSE as a column vector rather than a 3-dimensional array.
%
%   [RESPONSE,FREQ,TS] = FRDATA(SYS,J1,...,JN) extracts the data for the 
%   (J1,...,JN) entry in the model array SYS.
%
%   See also FRD.

%   Author(s): P. Gahinet, S. Almy
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $   $Date: 2010/03/31 18:37:19 $

% Detect 'v' flag
vflag = find(strncmpi(varargin,'v',1));
varargin(:,vflag) = [];

% Get data
try
   if isempty(varargin)
      % Possibly multiple models
      s = size(sys);
      nsys = prod(s(3:end));
      if nsys==0
         resp = zeros([s(1:2) 0 s(3:end)]);
         freq = zeros(0,1);
         Ts = 0;
      else
         nf = size(sys,'freq');
         resp = zeros([s(1:2) nf s(3:end)]);
         for ct=1:nsys
            [resp(:,:,:,ct),freq,Ts] = frdata_(sys,ct);
         end
      end
   else
      % Single model
      nsys = 1;
      [resp,freq,Ts] = frdata_(sys,varargin{:});
   end
catch ME
   ltipack.throw(ME,'command','frdata',class(sys))
end

% Return vectors if requested
if ~isempty(vflag) && nsys==1 && issiso(sys)
   % Convenience syntax for SISO case
   resp = resp(:);
end

% Obsolete TD output
if nargout>3,
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxTD')
   Td = (sys.InputDelay)';
end






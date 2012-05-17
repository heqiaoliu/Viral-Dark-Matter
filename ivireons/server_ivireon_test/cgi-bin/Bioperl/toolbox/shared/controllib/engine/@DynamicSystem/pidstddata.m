function [Kp,Ti,Td,N,Ts] = pidstddata(sys,varargin)
%PIDSTDDATA  Quick access to PID parameters.
%
%   [Kp,Ti,Td,N] = PIDSTDDATA(SYS) returns the Kp, Ti, Td, N parameters of a
%   PID controller in standard form represented by the SISO dynamic system
%   SYS. If SYS is a PIDSTD object, Kp, Ti, Td, N are the corresponding
%   properties of SYS. If SYS is not a PIDSTD object, Kp,Ti,Td,N are the
%   parameters of a PID controller equivalent to SYS. In that case SYS must
%   represent a valid PID controller.
%
%   [Kp,Ti,Td,N,Ts] = PIDSTDDATA(SYS) also returns the sample time Ts. Other
%   properties of SYS can be accessed with GET or by direct structure-like
%   referencing (e.g. SYS.InputName).
%
%   When SYS is an array of dynamic systems, Kp,Ti,Td,N are arrays of the
%   same size as SYS where Kp(m), Ti(m), Td(m) and N(m) give the PID
%   parameters of SYS(:,:,m). 
%
%   [Kp,Ti,Td,N,Ts] = PIDSTDDATA(SYS,J1,...,JN) extracts the data for the
%   (J1,...,JN) entry in the array of dynamic systems SYS where J1,...,JN
%   are indices in N dimensions. 
%
%   See also PIDDATA.

% Author(s): Rong Chen 08-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:36:53 $

s = size(sys);
nd = length(s);
try
    if isempty(varargin) && nd>2
        % multiple models
        ArraySize = s(3:end);
        Kp = zeros(ArraySize);
        Ti = zeros(ArraySize);
        Td = zeros(ArraySize);
        N = zeros(ArraySize);
        Ts = 0;
        for ct=1:numel(Kp)
            [Kp(ct),Ti(ct),Td(ct),N(ct),Ts] = pidstddata_(sys,ct);
        end
    else
        % single model
        [Kp,Ti,Td,N,Ts] = pidstddata_(sys,varargin{:});
    end
catch ME
    ltipack.throw(ME,'command','pidstddata',class(sys))
end

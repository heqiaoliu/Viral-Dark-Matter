function [Kp,Ki,Kd,Tf,Ts] = piddata(sys,varargin)
%PIDDATA  Quick access to PID parameters.
%
%   [Kp,Ki,Kd,Tf] = PIDDATA(SYS) returns the Kp, Ki, Kd, Tf parameters of a
%   PID controller in parallel form represented by the SISO dynamic system
%   SYS. If SYS is a PID object, Kp, Ki, Kd, Tf are the corresponding
%   properties of SYS. If SYS is not a PID object, Kp, Ki, Kd, Tf are the 
%   parameters of a PID controller equivalent to SYS. In that case SYS must
%   represent a valid PID controller.
%
%   [Kp,Ki,Kd,Tf,Ts] = PIDDATA(SYS) also returns the sample time Ts. Other
%   properties of SYS can be accessed with GET or by direct structure-like
%   referencing (e.g. SYS.InputName).
%
%   When SYS is an array of dynamic systems, Kp, Ki, Kd, Tf are arrays of
%   the same size as SYS where Kp(m), Ki(m), Kd(m) and Tf(m) give the PID
%   parameters of SYS(:,:,m).
%
%   [Kp,Ki,Kd,Tf,Ts] = PIDDATA(SYS,J1,...,JN) extracts the data for the
%   (J1,...,JN) entry in the array of dynamic systems SYS where J1,...,JN
%   are indices in N dimensions. 
%
%   See also PIDSTDDATA.

% Author(s): Rong Chen 08-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:36:51 $

s = size(sys);
nd = length(s);
try
    if isempty(varargin) && nd>2
        % multiple models
        ArraySize = s(3:end);
        Kp = zeros(ArraySize);
        Ki = zeros(ArraySize);
        Kd = zeros(ArraySize);
        Tf = zeros(ArraySize);
        Ts = 0;
        for ct=1:numel(Kp)
            [Kp(ct),Ki(ct),Kd(ct),Tf(ct),Ts] = piddata_(sys,ct);
        end
    else
        % single model
        [Kp,Ki,Kd,Tf,Ts] = piddata_(sys,varargin{:});
    end
catch ME
    ltipack.throw(ME,'command','piddata',class(sys))
end

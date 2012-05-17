function C = getPIDfromType(Type,Ts,varargin)
% GETPIDFROMTYPE  generates default PID object with desired Type and Ts.
%
 
% Author(s): Rong Chen 03-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:39:33 $

if nargin==2 || strcmpi(varargin{1},'parallel')
    switch lower(Type)
        case 'p'
            C = pid(1,'Ts',Ts);
        case 'i'
            C = pid(0,1,'Ts',Ts);
        case 'pi'
            C = pid(1,1,'Ts',Ts);
        case 'pd'
            C = pid(1,0,1,'Ts',Ts);
        case 'pdf'
            C = pid(1,0,1,10,'Ts',Ts);
        case 'pid'
            C = pid(1,1,1,'Ts',Ts);
        case 'pidf'
            C = pid(1,1,1,10,'Ts',Ts);
    end                
else
    switch lower(Type)
        case 'p'
            C = pidstd(1,'Ts',Ts);
        case 'pi'
            C = pidstd(1,1,'Ts',Ts);
        case 'pd'
            C = pidstd(1,inf,1,'Ts',Ts);
        case 'pdf'
            C = pidstd(1,inf,1,10,'Ts',Ts);
        case 'pid'
            C = pidstd(1,1,1,'Ts',Ts);
        case 'pidf'
            C = pidstd(1,1,1,10,'Ts',Ts);
    end                
end
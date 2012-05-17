function Gout = utPIDconvert(Gin,From,To,Ts)
% PID helper function

% This function converts a LTI model between different time domains

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:53:54 $

% tustin is default rate conversion method
if strcmpi(From,'continuous-time')
    if strcmpi(To,'continuous-time')
        Gout = Gin;
    else
        Gout = c2d(Gin,Ts,'tustin');
    end
else
    if strcmpi(To,'continuous-time')
        Gout = d2c(Gin,'tustin');
    else
        if Gin.Ts==Ts
            Gout = Gin;
        else
            Gout = d2d(Gin,Ts,'tustin');
        end
    end
end
                
function [Dd,gic] = c2d(Dc,Ts,options)
%C2D  Continuous-to-discrete conversion of state-space models.

%  Author(s): P. Gahinet
%  Revised: Murad Abu-Khalaf
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:44 $
nx = size(Dc.a,1);

method = options.Method(1);

% Check causality
if any(method=='zfi')
    [isProper,Dc] = isproper(elimZeroDelay(Dc),'explicit');
    if ~isProper
        ctrlMsgUtils.error('Control:transformation:c2d01','c2d')
    elseif nargout>1 && size(Dc.a,1)<nx
        ctrlMsgUtils.error('Control:general:NotSupportedSingularE','c2d')
    end
    nx = size(Dc.a,1);
end

switch method
    case 'm'
        % Use zpkdata algorithm
        try
            Dc = zpk(Dc);
        catch %#ok<CTCH>
            % Fails if Dc has internal delays that are not I/O delays
            ctrlMsgUtils.error('Control:transformation:c2d11')
        end
        Dd = ss(c2d(Dc,Ts,options));
        
    case 'z'
        % ZOH discretization
        [Dd,~,gic] = utDiscretizeZOH(Dc,Ts,(1:nx)');
        
    case 'f'
        % FOH discretization
        [Dd,~,gic] = utDiscretizeFOH(Dc,Ts,(1:nx)');
        
    case 'i'
        % IMP discretization
        [Dd,~,gic] = utDiscretizeIMP(Dc,Ts,(1:nx)');
        
    case 't'
        % This step is needed in order not to throw unnecessary warnings when
        % E is singular and gic is not requested.
        if nargout > 1
            [Dd,gic] = utDiscretizeTustin(Dc,Ts,options);
        else
            Dd = utDiscretizeTustin(Dc,Ts,options);
        end
end

% Check for overflow
% RE: can only happen for z,f,i options
if hasInfNaN(Dd.a)
    ctrlMsgUtils.error('Control:transformation:c2d02')
end

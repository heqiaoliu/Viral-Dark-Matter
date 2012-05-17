function Status = status(Constr, Context)
%STATUS  Generates status update when completing action on constraint

%   Author(s): A. Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:14 $

XUnits = Constr.xDisplayUnits;
YUnits = Constr.yDisplayUnits;
strP   = unitconv(Constr.Data.xCoords, Constr.Data.xUnits, XUnits);
strG   = unitconv(Constr.Data.yCoords, Constr.Data.yUnits, YUnits);
strLoc = unitconv(Constr.Origin, 'deg', XUnits);
gainphase = Constr.Data.Type;

switch Context
    case 'move'
        % Status update when completing move
        if strcmp(gainphase,'both')
            Status = sprintf('New margin requirement is PM > %0.3g %s, GM > %0.3g %s, at %0.3g %s.', ...
                strP, XUnits, strG, YUnits, strLoc, XUnits);
        elseif strcmp(gainphase,'phase')
            Status = sprintf('New phase margin requirement is %0.3g %s at %0.3g %s.', ...
                strP, XUnits, strLoc, XUnits);
        else
            Status = sprintf('New gain margin requirement is %0.3g %s at %0.3g %s.', ...
                strG, YUnits, strLoc, XUnits);
        end
        
    case 'resize'
        % Post new size
        if strcmp(gainphase,'both')
            Status = sprintf('New margin requirement is PM > %0.3g %s, GM > %0.3g %s, at %0.3g %s.', ...
                strP, XUnits, strG, YUnits, strLoc, XUnits);
        elseif strcmp(gainphase,'phase')
            Status = sprintf('New margin requirement is PM > %0.3g %s at %0.3g %s.', ...
                strP, XUnits, strLoc, XUnits);
        else
            Status = sprintf('New margin requirement is GM > %0.3g %s at %0.3g %s.', ...
                strG, YUnits, strLoc, XUnits);
        end
        
    case {'hover','hovermarker'}
        % Status when hovered
        if strcmp(gainphase,'both')
            str = sprintf('Design requirement: PM > %0.3g %s, GM > %0.3g %s, at %0.3g %s.', ...
                strP, XUnits, strG, YUnits, strLoc, XUnits);
        elseif strcmp(gainphase,'phase')
            str = sprintf('Design requirement: PM > %0.3g %s at %0.3g %s.', ...
                strP, XUnits, strLoc, XUnits);
        else
            str = sprintf('Design requirement: GM > %0.3g %s at %0.3g %s.', ...
                strG, YUnits, strLoc, XUnits);
        end
        
        Status = sprintf('%s\nLeft-click and drag to move this constraint.', str);
end

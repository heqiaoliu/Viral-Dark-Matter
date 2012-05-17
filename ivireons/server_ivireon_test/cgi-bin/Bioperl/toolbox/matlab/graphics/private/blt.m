function bool = blt( pj, h )
%BLT Returns FALSE if Lines and Text objects in Figure should be printed in black.
%   Looks at settings of DriverColor and DriverColorSet of PrintJob object
%   and the PrintTemplate object, if any, in the Figure.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2008/09/18 15:57:14 $

%DriverColorSet was turned to TRUE iff there was a device cmd line argument
%If there was a cmd line device argument we use the DriverColor resulting from it
%otherwise we look for a PrintTemplate object in the Figure
%If there is one we return its DriverColor boolean value.

%depviewer should always be printed in color mode to avoid
%the going through NODITHER
if( length(pj.Handles) == 1 && ...
    strcmpi(get(pj.Handles{1},'Tag'),'DAStudio.DepViewer') )
    bool = true;
    return;
end

if pj.DriverColorSet
    bool = pj.DriverColor;
else
    pt = getprinttemplate(h);
    if isempty( pt )
        if ispc & strncmp( pj.Driver, 'win', 3 )
            %PC driver properties' dialog allows users to set a color option.
            %PC code will call NODITHER if required.
            bool = 1; 
        else
            %Use setting based on default driver from PRINTOPT.
            bool = pj.DriverColor;
        end
    else
        bool = pt.DriverColor;
    end
end

bool = logical(bool);

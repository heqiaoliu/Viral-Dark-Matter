function isSL = isslhandle(h)
%ISSLHANDLE True for Simulink object handles for models or subsystem.
%   ISSLHANDLE(H) returns an array that contains 1's where the elements of
%   H are valid printable Simulink object handles and 0's where they are not.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.7 $

error( nargchk(1,1,nargin, 'struct') )

%See if it is a handle of some kind
isSL = ~ishghandle(h);
for i = 1:length(h(:))
    if isSL(i)
        %If can not GET the Type of the object then it is not an HG object.
        try
            %Use EVALC to suppress an error message when Simulink isn't fully installed.
            evalc('t = get_param(h(i),''type'');');
            isSL(i) = strcmp( 'block_diagram', get_param( h(i), 'type' ) );
            if ~isSL(i)
                isSL(i) = strcmp( 'SubSystem', get_param( h(i), 'blocktype' ) );
            end
        catch ex
            isSL(i) = false;
        end
    end
end
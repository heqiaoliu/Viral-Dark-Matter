function display(this)
% display UNITGAIN objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:44 $

% Author(s): Qinghua Zhang

ObjectName = getDisplayName(this);
if isscalar(this)
    disp([ObjectName ' object (no property).'])
else
    S = size(this);
    m = metaclass(this);
    P = eval([m.Name,'.getListOfVisibleProperties(m);']);
    if ~isempty(P)
        disp(sprintf('%sx%s  array of %s objects with following fields:',...
            num2str(S(1)),num2str(S(2)),ObjectName))
        disp(P)
    else
        disp(sprintf('%sx%s  array of Custom Network objects.',...
            num2str(S(1)),num2str(S(2))))
    end
end

% FILE END

function display(this)
% display IDNLFUN objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:58 $

% Author(s): Qinghua Zhang

ObjectName = getDisplayName(this);
if isscalar(this)
    G = get(this);
    disp([ObjectName,':'])
    disp(G)
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

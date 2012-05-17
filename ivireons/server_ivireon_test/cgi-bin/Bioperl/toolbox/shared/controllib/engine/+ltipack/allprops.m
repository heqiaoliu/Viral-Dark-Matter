function PublicProps = allprops(obj)
% Returns list of all public properties (visible or hidden)

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:42 $
mc = metaclass(obj);  % get meta.class
PP = findobj([mc.Properties{:}], 'GetAccess', 'public');
PublicProps = {PP.Name};

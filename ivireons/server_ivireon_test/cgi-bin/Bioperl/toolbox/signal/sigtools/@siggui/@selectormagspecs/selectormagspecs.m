function this = selectormagspecs
%SELECTORMAGSPECS  Constructor for the SELECTORMAGSPECS object
%   Construct this object with a cell array of options and 
%   a cell array comment

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/04/13 00:25:31 $

% First call the builtin constructor
this = siggui.selectormagspecs;

settag(this);
set(this, 'Version', 1.0);

% [EOF]

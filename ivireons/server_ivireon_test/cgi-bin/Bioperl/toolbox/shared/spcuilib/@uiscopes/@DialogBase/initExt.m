function initExt(this,titleSuffix,hScope)
%INIT Initialize method for base class.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/03/09 19:34:51 $
this.init(titleSuffix, hScope);

this.TitlePrefix = getTitleString(this);
this.TitleSuffix = sprintf(' - %s', titleSuffix);

this.initEventHandler(hScope);

% [EOF]

function h = copy(this)
%COPY  Copy for metadata objects

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2005/12/22 18:14:48 $
h = hds.metadata;
h.Units = this.Units;
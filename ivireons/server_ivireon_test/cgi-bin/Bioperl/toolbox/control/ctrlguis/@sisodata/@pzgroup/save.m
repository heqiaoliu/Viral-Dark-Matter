function Design = save(this)
%SAVE   Creates copy of pzgroup data.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:40:49 $

Design = struct('Type',this.Type,'Zero',this.Zero,'Pole',this.Pole);




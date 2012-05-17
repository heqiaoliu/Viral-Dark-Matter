function clearmetadata(this,eventData)
%CLEARMETADATA   Clear the metadata of the object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:56:54 $

setfdesign(this, []);
setfmethod(this, []);
set(this, 'privMeasurements', []);
set(this, 'privdesignmethod', []);

% Send the clearmetadata event in case object is contained in a multistage
send(this,'clearmetadata');

% [EOF]

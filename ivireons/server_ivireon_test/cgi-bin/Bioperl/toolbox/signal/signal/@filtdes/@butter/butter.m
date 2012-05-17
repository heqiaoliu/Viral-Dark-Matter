function d = butter
%BUTTER  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/13 00:03:56 $


d = filtdes.butter;

% Call super's constructor
classiciir_construct(d);

% Set the tag
set(d,'Tag','Butterworth','matchexactly','stopband');


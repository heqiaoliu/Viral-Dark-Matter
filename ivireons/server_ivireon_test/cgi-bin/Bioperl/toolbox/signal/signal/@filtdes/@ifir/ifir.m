function d = ifir
%IFIR  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:51 $

d = filtdes.ifir;

% Call super's constructor, do this after adding the order prop
designMethodwFs_construct(d);

% Set the tag
set(d,'Tag','Interpolated FIR');

% [EOF]

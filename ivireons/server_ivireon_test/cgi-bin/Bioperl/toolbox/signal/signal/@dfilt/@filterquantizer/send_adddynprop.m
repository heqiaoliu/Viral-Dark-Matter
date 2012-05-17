function send_adddynprop(q,dynprops)

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:57:56 $


% Send a adddynprop event
% dynprops is a structure with tow fields:
% - fied propstorm contains a cell array of strings of the prop to remove
% - fied plugin contains the new filterquantizer
send(q,'adddynprop', sigdatatypes.sigeventdata(q, 'adddynprop', dynprops));



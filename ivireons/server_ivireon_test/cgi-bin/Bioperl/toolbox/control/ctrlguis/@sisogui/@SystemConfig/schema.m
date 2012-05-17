function schema
%SCHEMA SISO Tool Analysis plot configuration

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 17:42:14 $

%---Register class
c = schema.class(findpackage('sisogui'),'SystemConfig');


%---Define properties

schema.prop(c, 'SISODB', 'handle');


schema.prop(c, 'Handles', 'MATLAB array'); % GUI items

schema.prop(c, 'Listeners',  'MATLAB array'); 


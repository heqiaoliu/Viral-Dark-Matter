function schema

% Copyright 2005-2006 The MathWorks, Inc.

% Register class (subclass)
p = findpackage('tsdata');
c = schema.class(p, 'tstableadaptor');

% Register class 
schema.prop(c,'Timeseries','MATLAB array'); 

%% EventRows identify the number of the event at each row in the table. 0
%% indicates that that row has no event.
schema.prop(c,'EventRows','MATLAB array'); 
schema.prop(c,'Time','MATLAB array'); 
schema.prop(c,'Data','MATLAB array'); 
schema.prop(c,'Quality','MATLAB array'); 
schema.prop(c,'Table','MATLAB array'); 
schema.prop(c,'ScrollPane','MATLAB array'); 
schema.prop(c,'TableModel','MATLAB array'); 
schema.prop(c,'NewEditRow','MATLAB array'); 
schema.prop(c,'NewEditRowNumber','MATLAB array');
schema.prop(c,'Tslistener','MATLAB array');






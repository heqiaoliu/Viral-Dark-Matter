function remove(h,ts,colind,T)
%interp
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/07/14 15:25:15 $


%% Recorder initialization
recorder = tsguis.recorder;

%% Remove blank rows
if length(colind)>1 && strcmp(h.Rowor,'off')
   Irowexcl = all(isnan(ts.Data(:,colind))')';
   if strcmp(recorder.Recording,'on')
       T.addbuffer(xlate('%% Removing rows'));
       T.addbuffer(['Irowexcl = all(isnan(', ts.Name, '.Data(:,[' ...
           num2str(colind) ']))'')'';'],ts);        
   end
elseif length(colind)>1 && strcmp(h.Rowor,'on')
   Irowexcl = any(isnan(ts.Data(:,colind))')';
   if strcmp(recorder.Recording,'on')
       T.addbuffer(xlate('%% Removing rows'));
       T.addbuffer(['Irowexcl = any(isnan(', ts.Name, '.Data(:,[' ...
           num2str(colind) ']))'')'';'],ts);        
   end      
else
   Irowexcl = isnan(ts.Data(:,colind));
   if strcmp(recorder.Recording,'on')
       T.addbuffer(xlate('%% Removing rows'));
       T.addbuffer(['Irowexcl = isnan(', ts.Name, '.Data(:,[' ...
           num2str(colind) ']));'],ts);        
   end        
end
ts.delsample('Value',ts.Time(find(Irowexcl)));
%ts.init(ts.Data(~Irowexcl,:),ts.Time(~Irowexcl));
if strcmp(recorder.Recording,'on')
    T.addbuffer([ts.Name ' = delsample(' ts.Name ',''Index'',find(Irowexcl));'])
end        


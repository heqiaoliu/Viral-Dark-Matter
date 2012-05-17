function update(this) 
% UPDATE 
%
% Update the visual with new data
 
% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:58:05 $

%Get the new data 
src = this.Application.DataSource;
newData = src.getRawData;
if isempty(newData)
    return;
end

%Get the new linear system to display
sys = newData.Data.LoggedData;
if strcmp(this.Application.DataSource.BlockHandle.FeedbackSign,'+1')
   %Nichols plot shows -ve feedback, if block uses positive switch system
   %sign
   sys = -1*sys;
end

%Create a new response and add to the plot
src = resppack.ltisource(sys,...
   'Name',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizedAtTime',...
   sprintf('%g',newData.Data.time)));
r = this.hPlot.addresponse(src);
r.DataFcn = {'magphaseresp' src 'nichols' r []};
initsysresp(r,'nichols',this.hPlot.Options,[])
%Draw the new response
r.draw;

%Update the legend
this.updateLegend
end
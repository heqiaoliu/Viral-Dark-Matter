function update(this)
% UPDATE
%
% Update the visual with new data

% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/05/10 17:58:03 $

%Get the new data
src = this.Application.DataSource;
newData = src.getRawData;
if isempty(newData)
   return;
end

%Get the new linear system to display
sys = newData.Data.LoggedData;

%Create a new response and add to the plot
src = resppack.ltisource(sys,...
   'Name',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizedAtTime',...
   sprintf('%g',newData.Data.time)));
if strcmp(this.PlotType,'table')
   this.hPlot.update(sys,newData.Data.time);
else
   r = this.hPlot.addresponse(src);
   switch this.PlotType
      case 'nyquist'
         r.DataFcn = {'nyquist' src r []};
         initsysresp(r,'nyquist',this.hPlot.Options,[]);
      case 'bode'
         r.DataFcn = {'magphaseresp' src 'bode' r []};
         initsysresp(r,'bode',this.hPlot.Options,[])
      otherwise
         %Default to Nichols
         
         %Nichols plot shows -ve feedback, if block uses positive switch system
         %sign
         if strcmp(this.Application.DataSource.BlockHandle.FeedbackSign,'+1')
            src = resppack.ltisource(-1*sys,...
               'Name',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizedAtTime',...
               sprintf('%g',newData.Data.time)));
         end
         
         r.DataFcn = {'magphaseresp' src 'nichols' r []};
         initsysresp(r,'nichols',this.hPlot.Options,[])
   end
   %Draw the new response
   r.draw;
   %Update the legend
   this.updateLegend
end
end
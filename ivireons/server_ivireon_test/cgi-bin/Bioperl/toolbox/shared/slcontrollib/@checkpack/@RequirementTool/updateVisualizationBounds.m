function updateVisualizationBounds(this) 
%

% UPDATEVISUALIZATIONBOUNDS push bound data from block to visualization
%
 
% Author(s): A. Stothert 12-Jan-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4.2.1 $ $Date: 2010/07/06 14:41:42 $

if this.PreventVisUpdate
   return
end

hVis = this.Application.Visual;
if ~hVis.canShowBounds
   %Nothing to do, quick return
   return
end

try
   hReqs = getbounds(getFullName(this.Application.DataSource.BlockHandle));
catch E
   msg = DAStudio.message('SLControllib:checkpack:errConstructingBounds');
   this.Application.MessageLog.add('fail','Extension',msg,E.message)
   hReqs = [];
end
hReq = [];
for ct = 1:numel(hReqs)
   hReq = vertcat(hReq,hReqs{ct}(:)); %#ok<AGROW>
end

%Get patch colour data for drawing requirements
cEnabled  = hVis.hPlot.Options.RequirementColor;
cDisabled = hVis.hPlot.Options.DisabledRequirementColor;

%Can we reuse any existing bounds?
nR = numel(this.hReq);
if nR > 0
   useR = zeros(nR,1);
   for ct = 1:numel(hReq)  %Loop over bounds we want to add
      ctR = 1;
      found = false;
      while ctR <= nR && ~found  %Search bounds we already have for match
         if useR(ctR) == 0
            %Can reuse if type (<=, >=) and number of edges is the same
            hCandidate = this.hReq(ctR).getRequirementObject;
            if strcmp(class(hReq(ct)),class(hCandidate)) && ...
                  hReq(ct).isLowerBound == hCandidate.isLowerBound && ...
                  all(size(hReq(ct).getData('xdata')) == size(hCandidate.getData('xdata')));
               found = true;
               useR(ctR) = ct;
               if hCandidate.isEnabled ~= hReq(ct).isEnabled;
                  hCandidate.isEnabled = hReq(ct).isEnabled;
                  if hCandidate.isEnabled
                     set(this.hReq(ctR),'PatchColor',cEnabled);
                  else
                     set(this.hReq(ctR),'PatchColor',cDisabled);
                  end
               end
               hCandidate.setData(...
                  'xdata',hReq(ct).getData('xdata'), ...
                  'ydata',hReq(ct).getData('ydata'), ...
                  'OpenEnd',hReq(ct).getData('OpenEnd'));
               hCandidate.setData('type',hReq(ct).getData('type'));
               if isprop(hCandidate,'FeedbackSign')
                  hCandidate.FeedbackSign = hReq(ct).FeedbackSign;
               end
            end
         end
         ctR = ctR + 1;
      end
   end
   %Remove any bounds that aren't reused
   idx = useR==0;
   delete(this.hReq(idx)); %fires listener to cleanup stale hReq handles
   %From the list of bounds to add remove those bounds that have been 
   %'added' by reusing an existing bound
   delete(hReq(useR(~idx)));
   hReq(useR(~idx)) = [];
end

%Add any bounds
if ~isempty(hReq)
   hVis = this.Application.Visual;
   for ct = 1:numel(hReq)
      %Add the requirement to the visualization, this will also register
      %the new requirement with this tool
      hVis.addconstr(hReq(ct));
   end
end

%Any updates made above will put the tool in a dirty state. But these
%changes have been made because of block or block dialog changes so set the
%dirty state false.
this.isDirty = false;
end


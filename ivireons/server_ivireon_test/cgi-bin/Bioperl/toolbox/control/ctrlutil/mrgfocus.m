function focus = mrgfocus(FRanges,SoftFlags)
%MRGFOCUS  Merges frequency ranges into single focus.
%
%  FOCUS = MRGFOCUS(FRANGES,SOFTFLAGS) merges a list of ranges
%  into a single range. The logical vector SOFTFLAGS signals which
%  ranges are soft and can be  ignored when well separated from 
%  the remaining dynamics (these correspond to pseudo integrators 
%  or derivators, or response w/o dynamics)

%  Author(s): P. Gahinet
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $ $Date: 2006/06/20 20:03:35 $

% Merge well-defined ranges (SOFTRANGE=0)
focus = LocalMergeRange(FRanges(~SoftFlags));

% Incorporate soft range contribution (SOFTRANGE=1)
if isempty(focus)
    focus = LocalMergeRange(FRanges(SoftFlags));
else
    % Discard soft ranges that are separated by at least 2 decades from
    % remaining dynamics.
    for ct=1:length(SoftFlags)
       fr = FRanges{ct};
       if ~isempty(fr)
          SoftFlags(ct) = (SoftFlags(ct) && fr(1)<100*focus(2) && fr(2)>focus(1)/100);
       end
    end
    focus = LocalMergeRange([{focus};FRanges(SoftFlags)]);
end


%--------------- Local Functions ----------------------------

function focus = LocalMergeRange(FRanges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct=1:length(FRanges)
    focus = [focus ; FRanges{ct}];
    focus = [min(focus(:,1)) , max(focus(:,2))];
end
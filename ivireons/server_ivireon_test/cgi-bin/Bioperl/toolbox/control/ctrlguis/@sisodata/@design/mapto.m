function init2 = mapto(init1,init2,currentData)
% Transfer settings when changing configuration.
% 
%   Returns logical vector MAPPEDC indicating which 
%   tuned models in INIT2 have been inherited from
%   INIT1.

%   Authors: P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:40:07 $
init2.Name = init1.Name;
fn = fieldnames(currentData);

% Transfer feeback signs
if length(init1.FeedbackSign)==length(init2.FeedbackSign)
   init2.FeedbackSign = init1.FeedbackSign;
end

% Transfer data for plant components with the same identifier
% otherwise try reusing current value
[junk,ia] = intersect(init2.Fixed,fn);
% for ct=1:length(ia)
%    G = init2.Fixed{ia(ct)};
%    set(init2.(G), currentData.(G));
% end
[junk,ia] = intersect(init2.Fixed,init1.Fixed);
for ct=1:length(ia)
   G = init2.Fixed{ia(ct)};
   init2.(G) = init1.(G);
end

% Transfer data for compensators with the same identifier,
% otherwise try reusing current value
[junk,ia] = intersect(init2.Tuned,fn);
% for ct=1:length(ia)
%    C = init2.Tuned{ia(ct)};
%    set(init2.(C), currentData.(C));
% end
[junk,ia] = intersect(init2.Tuned,init1.Tuned);
for ct=1:length(ia)
   C = init2.Tuned{ia(ct)};
   init2.(C) = init1.(C);
end


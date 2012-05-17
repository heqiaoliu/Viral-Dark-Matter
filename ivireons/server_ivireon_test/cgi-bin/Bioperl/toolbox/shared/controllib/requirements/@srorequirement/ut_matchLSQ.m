function v = ut_matchLSQ(req,v)
% UT_MATCHLSQ a function to ensure the order of the returned values is 
% consistent (in a least squares sense) with the order returned the last 
% time a requirement called this function.
%
% v = srorequirement.ut_matchLSQ(req,v)
%
% Inputs:
%    req - the requirement calling this function, a
%          srorequirement.requirement object
%    v   - a vector of complex numbers in unsorted order
%
% Outputs:
%    v - a vector of complex numbers ordered consistently with the last time
%        the requirement sorted values
%
 
% Author(s): A. Stothert 19-Mar-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:24 $

persistent Keys Values

if isempty(Keys)
   %Construct Map to store previously computed values.
   %Map keys will be the requirements, and map entries the values. 
   Keys = [];
   Values = {};
end

%Makesure conjugate pairs appear sequentially
idx = abs(imag(v))>eps;
v = [v(idx); sort(v(~idx),1,'descend')]; %Complex first then reals in descending  
ct = 1;
while ct < numel(v)
    if abs(imag(v(ct))) > eps
       %Have complex value search for conjugate and pair them in the list
       idx = abs(v-conj(v(ct))) < eps;
       if ct < numel(v)
          v(idx) = v(ct+1);
          v(ct+1) = conj(v(ct));
          ct = ct + 2;
       end
    else
       ct = ct + 1;
    end
end

idx = Keys==req;
if any(idx)
   %Have previously computed values for this requirement
   oldV = Values{idx};
   if numel(oldV) == numel(v)
      %Order the values so they are consistent with the order they
      %were last computed
      v = localMatchLSQ(oldV,v);
      %Store the new values in the map
      Values{idx} = v;
   else
      %Number of values changed for some reason, reset the map entry
      Values{idx} = v;
   end
else
   %First time sorting values for this requirement, add it to the
   %map
   Keys = [Keys; req];
   Values = [Values; {v}];
end
end

function v2 = localMatchLSQ(v1,v2)
%LOCALMATCHLSQ helper to match values in one vector with values in another.
%matching is done on a minimum distance criteria and care is take to
%ensure complex conjugates map to either complex conjugates or a pair of
%real values. Similarly care is take to ensure that either 2 reals or a
%conjugate pair map to a conjugate pair.
%
%Note: assumes complex conjugate pairs in v1 appear next to each other,
%similarly for v2

p = length(v1); %Number of elements to match

% Form gap matrix
vones = ones(p,1);
v21 = v2(:,1).';
Mdiff = abs(v21(vones,:) - v1(:,vones));
Mdiff(isnan(Mdiff)) = Inf;

%Construct an empty matching vector v1m. The vector v1m is the same length 
%as v1 and each entry gives the index of the element in v2 that matches the
%v1 entry, i.e., v1m(3) gives the index into v2 that matches v1(3). 
%
v1m = nan(p,1); %When finished we return v2(v1m)

%Find complex entries in v1 and v2
iv1c = abs(imag(v1)) > 0; 
iv2c = abs(imag(v2)) > 0;

if ~any(iv1c) || ~any(iv2c)
   %Nothing to do as no complex pairs and v1,v2 are sorted in descending
   %magnitude
   return
end
   

%Match complex entries in v1
for ct=1:p
   if iv1c(ct)
      %Found an unmatched complex entry
      [junk,idx] = min(Mdiff(ct,:));
      if iv2c(idx)
         %Match is complex
         v1m(ct) = idx;
         %Enforce conjugate maps to conjugate, note conjugate pairs always
         %appear as neighbours in v1 and v2.
         v2_conj = conj(v2(idx));
         if idx+1<=p && abs(v2_conj-v2(idx+1)) < eps
            idx2 = idx+1;
         elseif idx-1>0 && abs(v2_conj-v2(idx-1)) < eps
            idx2 = idx-1;
         end
         v1m(ct+1) = idx2;
         %Remove matched complex pairs from search list
         iv1c([ct, ct+1])  = false;
         iv2c(idx)  = false;
         iv2c(idx2) = false;
      else
         %Match is real, find match for complex conjugate
         rData       = Mdiff(ct+1,:);
         rData(idx)  = inf;
         [junk,idx2] = min(rData);
         if iv2c(idx2)
            %Matched conjugate with complex
            v1m(ct+1) = idx2;
            %Enforce conjugate maps to conjugate, note conjugate pairs always
            %appear as neighbours in v1 and v2.
            v2_conj = conj(v2(idx2));
            if idx2+1<=p && abs(v2_conj-v2(idx2+1)) < eps
               idx = idx2+1;
            elseif idx2-1>0 && abs(v2_conj-v2(idx2-1)) < eps
               idx = idx2-1;
            end
            v1m(ct) = idx;
            %Remove matched complex pairs from search list
            iv1c([ct, ct+1])  = false;
            iv2c(idx)  = false;
            iv2c(idx2) = false;
         else
            %Matched conjugate with real
            v1m(ct)   = idx;
            v1m(ct+1) = idx2;
            %Remove matched complex pairs from search list
            iv1c([ct, ct+1])  = false;
         end
      end
      %Mark matches in Mdiff to ensure they're not selected again
      Mdiff(ct,:)   = inf;
      Mdiff(ct+1,:) = inf;
      Mdiff(:,idx)  = inf;
      Mdiff(:,idx2) = inf;
   end
end

%Match any unmatched complex entries in v2. 
%
%All the unmatched complex entries in v2 must match to reals in v1 
%as we matched all the complex entries in v1 in the previous step.
for ct=1:p
   if iv2c(ct)
      %Found an unmatched complex entry
      [junk,idx] = min(Mdiff(:,ct));
      %Find match for conjugate, be careful to eliminate proposed match
      rData = Mdiff(:,ct+1);
      rData(idx) = inf;
      [junk,idx2] = min(rData);
      %Store matches
      v1m(idx)   = ct;
      v1m(idx2)  = ct+1;
      %Remove matched complex pairs from search list
      iv2c([ct, ct+1]) = false;
      %Mark matches in Mdiff to ensure they're not selected again
      Mdiff(:,ct)   = inf;
      Mdiff(:,ct+1) = inf;
      Mdiff(idx,:)  = inf;
      Mdiff(idx2,:) = inf;
   end
end

%Left with matches of reals to reals
%
%Should only have unmatched reals in v1 and v2 because complex entries were 
%matched up in last step
iv1r = isnan(v1m);  %Unmatched real entries in v1
for ct = 1:p
   if iv1r(ct)
      %Found an unmatched real
      [junk,idx] = min(Mdiff(ct,:));
      v1m(ct) = idx;
      %Remove matched real from search list
      iv1r(ct) = false;
      %Mark matches in Mdiff to ensure they're not selected again
      Mdiff(ct,:)  = inf;
      Mdiff(:,idx) = inf;
   end
end

%Reorder v2
v2 = v2(v1m);
end





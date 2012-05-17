function v2=v2sort(v1,v2)
%V2SORT Sorts two vectors and then removes missing elements.
%
% This is a helper function.

%   Given two complex vectors v1 and v2, v2 is returned with
%       the nearest elements which are missing from v1 removed.
%     Syntax:  v2=V2SORT(v1,v2) 

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2008/12/01 07:40:37 $

lv1=length(v1);
lv2=length(v2);
if lv1>lv2
    % For each element of v1: Find the minimum difference between the
    % element and the vector v2
    ind = i_findMinDiff(v1, v2, lv1, lv2);

    % Add elements from v1 to v2. Select elements which have the minimum
    % difference to v2.
    lv2init=lv2;
    for i=1:lv1-lv2
        i2=min([lv2,ind(i)-1]);
        if ind(i)-1<=lv2init && i<lv2init
            v2=[v2((1:i2)');v1(ind(i));v2((i2+1:lv2)')];
        else
            v2=[v2;v1(lv2+1)];
        end
        lv2=lv2+1;
    end
else   
    % For each element of v2: Find the minimum difference between the
    % element and the vector v1  
    ind = i_findMinDiff(v2, v1, lv2, lv1);
    
    % Remove missing elements
    v2(ind(1:lv2-lv1))=[];
end

function ind = i_findMinDiff(v1, v2, lv1, lv2)
%I_FINDMINDIFF(V1, V2, LV1, LV2) first finds the minimum absolute
%difference between each element of V1 and the vector V2, i.e.
%
%        For j = 1:length(V1) 
%           TEMP(j) = min (V1(j) - V2(i))
%                      i
% 
% The vector TEMP is sorted in decreasing value and the vector of indices
% from the SORT function is returned.

% Testing on this function showed that we see a speed improvement in moving
% to a for loop implementation when the repmatted matrix "diff" is exceeds
% approximately 20000 elements in size. 
if lv1*lv2 < 20000
    % For small vectors it is quickest to perform all the differences
    % (V1(j) - V2(i)) in one matrix subtraction
    v1ones=ones(1,lv1);
    v2ones=ones(lv2,1);
    diff=abs((v2ones*v1.')-(v2*v1ones));
    temp=min(diff,[],1);
else
    % For larger vectors it is quicker to perform the minimization for each
    % element of V1 in a for loop. This also prevents us running out of
    % memory by not having to create the difference matrix (diff in the
    % "if" clause above) for large vectors.
    temp = zeros(1, lv1);
    for i = 1:lv1
        diffV1eltV2 = abs(v1(i) - v2);
        temp(i) = min(diffV1eltV2);
    end
end    
[dum,ind]=sort(-temp);



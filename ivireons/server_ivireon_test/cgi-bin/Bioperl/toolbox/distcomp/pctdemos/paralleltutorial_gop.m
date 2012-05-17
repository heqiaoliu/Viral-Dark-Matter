%% Using GOP to Achieve MPI_Allreduce Functionality
% In this demo, we look at the |gop| function and the functions that build
% on it: |gplus| and |gcat|.  These seemingly simple functions turn out to
% be very powerful tools in parallel programming.
%
% The |gop| function allows us to perform any associative binary operation
% on a variable that is defined on all the labs.  This allows us not only
% to sum a variable across all the labs, but also to find its minimum and
% maximum across the labs, concatenate them, and perform many other useful
% operations.
%
% Related Documentation:
% 
% * <matlab:doc('spmd') spmd reference page> in the 
% Parallel Computing Toolbox(TM) User's Guide

%   Copyright 2007-2008 The MathWorks, Inc.

%%
% The code shown in this demo can be found in this function:
function paralleltutorial_gop


%% Introduction
% When doing parallel programming, we often run into the situation of
% having a variable defined on all the labs, and we want to perform an
% operation on the variable as it exists on all the labs.  For example, if
% we enter an spmd statement and define
spmd
    x = labindex
end

%%
% on all the labs, we might want to calculate the sum of the values of |x|
% across the labs.  This is exactly what the |gplus| operation does, it
% sums the |x| across the labs and duplicates the result on all labs:
spmd
    s = gplus(x);
end
%%
% The variables assigned to inside an spmd statement are represented on the
% client as Composite.  We can bring the resulting values from the labs to
% the client by indexing into the Composite much like that of cell arrays:
s{1} % Display the value of s on lab 1.  All labs store the same value.

%%
% Also, |gop|, |gplus|, and |gcat| allow us to specify a single lab to
% which the function output should be returned, and they return an empty
% vector on the other labs.
spmd
    s = gplus(x, 1);
end
s{1}

%%
% This demo shows how to perform a host of operations similar to addition
% across all the labs.  In MPI, these are known as collective operations,
% such as MPI_SUM, MPI_PROD, MPI_MIN, MPI_MAX, etc.

%% Create the Input Data for Our Examples
% The data we use for all our examples is very simple: a 1-by-2 variant
% array that is only slightly more complicated than the |x| we defined in
% the beginning:
spmd
    x = labindex + (1:2)
end

%% Using GPLUS and GCAT
% Now that we have initialized our vector |x| to different values on the
% labs, we can ask questions such as what is the element-by-element sum of
% the values of |x| across the labs? What about the product, the minimum,
% and the maximum?  As to be expected from our introduction,
spmd
    s = gplus(x);
end
s{1}

%%
% returns the element-by-element addition of the values of |x|.  However,
% |gplus| is only a special case of the |gop| operation, short for Global
% OPeration.  The |gop| function allows us to perform any associative
% operation across the labs on the elements of a variant array.  The most
% basic example of an associative operation is addition; it is associative
% because addition is independent of the grouping which is used:
%%
%  (a + b) + c = a + (b + c)
%%
% In MATLAB(R), addition can be denoted by the |@plus| function handle, so
% we can also write |gplus(x)| as
spmd
    s = gop(@plus, x);
end
s{1}

%%
% We can concatenate the vector |x| across the labs by using the |gcat|
% function, and we can choose the dimension to concatenate along.  
spmd
    y1 = gcat(x, 1); % Concatenate along rows.
    y2 = gcat(x, 2); % Concatenate along columns.
end
y1{1} 
y2{1}

%% Other Elementary Uses of GOP
% It is simple to calculate the element-by-element product of the values of
% |x| across the labs:
spmd
    p = gop(@times, x);
end
p{1}


%%
% We can also find the element-by-element maximum of |x| across the labs:
spmd
    M = gop(@max, x);
    m = gop(@min, x);
end
M{1}
m{1}

%% Logical Operations
% MATLAB has even more built-in associative operations.  The logical AND,
% OR, and XOR operations are represented by the |@and|, |@or|, and |@xor|
% function handles.  For example, look at the logical array
spmd
    y = (x > 4)
end    

%%
% We can then easily perform these logical operations on the elements of
% |y| across the labs:
spmd
    yand = gop(@and, y);
    yor = gop(@or, y);
    yxor = gop(@xor, y);
end    
yand{1}
yor{1}
yxor{1}

%% Bitwise Operations
% To conclude our tour of the associative operations that are built into
% MATLAB, we look at the bitwise AND, OR, and XOR operations.  These are
% represented by the |@bitand|, |@bitor|, and |@bitxor| function handles.
spmd
    xbitand = gop(@bitand, x);
    xbitor = gop(@bitor, x);
    xbitxor = gop(@bitxor,  x);
end    
xbitand{1}
xbitor{1}
xbitxor{1}

%% Finding Locations of Min and Max
% We need to do just a little bit of programming to find the labindex
% corresponding to where the element-by-element maximum of |x| across the
% labs occurs.  We can do this in just a few lines of code:
type pctdemo_aux_gop_maxloc

%%
% and when the function has been implemented, it can be applied just as
% easily as any of the built-in operations:
spmd
    [maxval, maxloc] = pctdemo_aux_gop_maxloc(x);
end
[maxval{1}, maxloc{1}]

%%
% Similarly, we only need a few lines of code to find the labindex where
% the element-by-element minimum of |x| across the labs occurs:
type pctdemo_aux_gop_minloc

%%
% We can then easily find the minimum with |gop|:
spmd
    [minval, minloc] = pctdemo_aux_gop_minloc(x);
end
[minval{1}, minloc{1}]

displayEndOfDemoMessage(mfilename)

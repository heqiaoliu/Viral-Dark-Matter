function x = capital(x)
%CAPITAL Capitalize first letter of each word in string.

% only works for one word!
if ~isempty(x)
    x=lower(x);
    x(1)=upper(x(1));
end

% [EOF]

function b = isOperator(topic)
    b = length(topic)<=3 && all(isstrprop(topic, 'alphanum')) == 0;
end

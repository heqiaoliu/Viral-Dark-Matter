function it = is_timer_stale(t)
    it = true;
    if (~isempty(t) && any(t==timerfindall))
        it = false;
    end
    
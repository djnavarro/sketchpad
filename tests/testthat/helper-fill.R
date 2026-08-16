# Shared helper for tests exercising the fill class: unwraps a fill object's
# stored value (resolving against aspect, default 1) the same way draw()'s
# own geometry_grob() does. A bare (non-fill) value passes through
# unchanged, via resolve_fill()'s own defensive fallback.
fv <- function(f, aspect = 1) resolve_fill(f, aspect)

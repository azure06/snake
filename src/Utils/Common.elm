module Utils.Common exposing (flip, iif)


iif : (() -> Bool) -> (() -> a) -> (() -> a) -> a
iif condition a b =
    if condition () then
        a ()

    else
        b ()


flip : (a -> b -> c) -> b -> a -> c
flip func a b =
    func b a

module Utils.Circle exposing (distance, filterIntersect, intersect, intersectAny)


type alias Tuple =
    ( Float, Float )


type alias NestedTuple =
    ( ( Float, Float ), Float )


distance : Tuple -> Tuple -> Float
distance ( x1, y1 ) ( x2, y2 ) =
    sqrt ((x2 - x1) ^ 2 + (y2 - y1) ^ 2)


intersect : NestedTuple -> NestedTuple -> Bool
intersect ( ( x1, y1 ), size1 ) ( ( x2, y2 ), size2 ) =
    distance ( x1, y1 ) ( x2, y2 ) <= (size1 / 2 + size2 / 2)


filterIntersect : NestedTuple -> List NestedTuple -> List NestedTuple
filterIntersect tuple =
    List.filter (intersect tuple)


intersectAny : NestedTuple -> List NestedTuple -> Bool
intersectAny tuple =
    List.any (intersect tuple)

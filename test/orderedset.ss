(var OrderedSet) 
(set! OrderedSet (function (arr ordered? uniq?)
    (set! this.items (arr or #[]))
    (if uniq?.not this.uniquify
        ordered?.not this.sort)
    this))

(OrderedSet implement #{
    "length": (function () this.items.length)
    
    "contains": (function (needle) 
                (this.items any (function (item) 
                    (item == needle))))

    "sort": (function () this.items.sort)

    "uniquify": (function () 
                (var items)
                (set! items #[])
                (this.items each (function (item)
                                    (if ((items indexOf item) != -1)
                                        (items push item))))
                items)
})

(set! exports.OrderedSet OrderedSet)

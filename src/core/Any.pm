my class Pair                   { ... }
my class Range                  { ... }
my class X::Adverb::Slice       { ... }
my class X::Bind                { ... }
my class X::Bind::Slice         { ... }
my class X::Bind::ZenSlice      { ... }
my class X::Item                { ... }
my class X::Match::Bool         { ... }
my class X::Pairup::OddNumber   { ... }
my class X::Subscript::Negative { ... }

my role  Numeric { ... }

my class Any { # declared in BOOTSTRAP
    # my class Any is Mu {

    multi method ACCEPTS(Any:D: Mu \a) { self === a }
    multi method ACCEPTS(Any:U: Any \topic) { # use of Any on topic to force autothreading
        nqp::p6bool(nqp::istype(topic, self)) # so that all(@foo) ~~ Type works as expected
    }

    method invoke(|c) {
        DEPRECATED('CALL-ME',|<2015.03 2015.09>);
        self.CALL-ME(|c);
    }

    method exists_key(|c) is nodal {
        DEPRECATED('EXISTS-KEY',|<2015.03 2015.09>);
        self.EXISTS-KEY(|c);
    }

    proto method EXISTS-KEY(|) is nodal { * }
    multi method EXISTS-KEY(Any:U: $) { False }
    multi method EXISTS-KEY(Any:D: $) { False }

    method delete_key(|c) is nodal {
        DEPRECATED('DELETE-KEY',|<2015.03 2015.09>);
        self.DELETE-KEY(|c);
    }

    proto method DELETE-KEY(|) is nodal { * }
    multi method DELETE-KEY(Any:U: $) { Nil }
    multi method DELETE-KEY(Any:D: $) {
        fail "Can not remove values from a {self.^name}";
    }

    method delete_pos(|c) is nodal {
        DEPRECATED('DELETE-POS',|<2015.03 2015.09>);
        self.DELETE-POS(|c);
    }

    proto method DELETE-POS(|) is nodal { * }
    multi method DELETE-POS(Any:U: $pos) { Nil }
    multi method DELETE-POS(Any:D: $pos) {
        fail "Can not remove elements from a {self.^name}";
    }

    proto method list(|) is nodal { * }
    multi method list(Any:U:) { infix:<,>() }
    multi method list(Any:D:) { infix:<,>(self) }

    proto method flat(|) is nodal { * }
    multi method flat() { self.list.flat }

    proto method eager(|) is nodal { * }
    multi method eager() { self.list.eager }

    # derived from .list
    proto method List(|) is nodal { * }
    multi method List() { self.list.List }
    proto method Slip(|) is nodal { * }
    multi method Slip() { self.list.Slip }
    proto method Array(|) is nodal { * }
    multi method Array() { self.list.Array }

    proto method hash(|) is nodal { * }
    multi method hash(Any:U:) { my % = () }
    multi method hash(Any:D:) { my % = self }

    # derived from .hash
    proto method Hash(|) is nodal { * }
    multi method Hash() { self.hash.Hash }

    proto method elems(|) is nodal { * }
    multi method elems(Any:U:) { 0 }
    multi method elems(Any:D:) { self.list.elems }

    proto method end(|) is nodal { * }
    multi method end(Any:U:) { -1 }
    multi method end(Any:D:) { self.list.end }

    proto method keys(|) is nodal { * }
    multi method keys(Any:U:) { () }
    multi method keys(Any:D:) { self.list.keys }

    proto method kv(|) is nodal { * }
    multi method kv(Any:U:) { () }
    multi method kv(Any:D:) { self.list.kv }

    proto method values(|) is nodal { * }
    multi method values(Any:U:) { () }
    multi method values(Any:D:) { self.list }

    proto method pairs(|) is nodal { * }
    multi method pairs(Any:U:) { () }
    multi method pairs(Any:D:) { self.list.pairs }

    proto method antipairs(|) is nodal { * }
    multi method antipairs(Any:U:) { () }
    multi method antipairs(Any:D:) { self.list.antipairs }

    proto method invert(|) is nodal { * }

    proto method pick(|) is nodal { * }
    multi method pick()   { self.list.pick     }
    multi method pick($n) { self.list.pick($n) }

    proto method roll(|) is nodal { * }
    multi method roll()   { self.list.roll     }
    multi method roll($n) { self.list.roll($n) }

    proto method classify(|) is nodal { * }
    multi method classify() {
        die "Must specify something to classify with, a Callable, Hash or List";
    }
    multi method classify(Whatever) {
        die "Doesn't make sense to classify with itself";
    }
    multi method classify($test, :$into!, :&as)   {
        ( $into // $into.new ).classify-list( $test, self.list, :&as);
    }
    multi method classify($test, :&as)   {
        Hash.^parameterize(Any,Any).new.classify-list( $test, self.list, :&as );
    }

    proto method categorize(|) is nodal { * }
    multi method categorize() {
        die "Must specify something to categorize with, a Callable, Hash or List";
    }
    multi method categorize(Whatever) {
        die "Doesn't make sense to categorize with itself";
    }
    multi method categorize($test, :$into!, :&as) {
        ( $into // $into.new ).categorize-list( $test, self.list, :&as );
    }
    multi method categorize($test, :&as) {
        Hash.^parameterize(Any,Any).new.categorize-list($test, self.list, :&as);
    }

    method rotor(|c) is nodal { self.list.rotor(|c) }
    method reverse() is nodal { self.list.reverse }
    method combinations(|c) is nodal { self.list.combinations(|c) }
    method permutations(|c) is nodal { self.list.permutations(|c) }
    method join($separator) is nodal { self.list.join($separator) }

    # XXX GLR should move these
    method nodemap(&block) is rw is nodal { nodemap(&block, self) }
    method duckmap(&block) is rw is nodal { duckmap(&block, self) }
    method deepmap(&block) is rw is nodal { deepmap(&block, self) }

    # XXX GLR Do we need tree post-GLR?
    #proto method tree(|) is nodal { * }
    #multi method tree(Any:U:) { self }
    #multi method tree(Any:D:) {
    #    nqp::istype(self,Positional)
    #        ?? LoL.new(|MapIter.new(self.list, { .tree }, Mu).list).item
    #        !! self
    #}
    #multi method tree(Any:D: Whatever ) { self.tree }
    #multi method tree(Any:D: Int(Cool) $count) {
    #    nqp::istype(self,Positional) && $count > 0
    #        ?? LoL.new(|MapIter.new(self.list, { .tree($count - 1) }, Mu).list).item
    #        !! self
    #}
    #multi method tree(Any:D: *@ [&first, *@rest]) {
    #    nqp::istype(self,Positional)
    #        ?? @rest ?? first(MapIter.new(self.list, { .tree(|@rest) }, Mu).list)
    #                 !! first(self.list)
    #        !! self
    #}

    # auto-vivifying
    proto method push(|) is nodal { * }
    multi method push(Any:U \SELF: *@values) {
        SELF = nqp::istype(SELF,Positional) ?? SELF.new !! Array.new;
        SELF.push(@values);
    }

    proto method unshift(|) is nodal { * }
    multi method unshift(Any:U \SELF: *@values) {
        SELF = Array.new;
        SELF.unshift(@values);
    }

    method exists_pos(|c) is nodal {
        DEPRECATED('EXISTS-POS',|<2015.03 2015.09>);
        self.EXISTS-POS(|c);
    }

    proto method EXISTS-POS(|) is nodal { * }
    multi method EXISTS-POS(Any:U: Any:D $) { False }
    multi method EXISTS-POS(Any:U: Any:U $pos) is rw {
        die "Cannot use '{$pos.^name}' as an index";
    }

    multi method EXISTS-POS(Any:D: int \pos) {
        nqp::p6bool(nqp::iseq_i(pos,0));
    }
    multi method EXISTS-POS(Any:D: Int:D \pos) {
        pos == 0;
    }
    multi method EXISTS-POS(Any:D: Num:D \pos) {
        X::Item.new(aggregate => self, index => pos).throw
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
        pos == 0;
    }
    multi method EXISTS-POS(Any:D: Any:D \pos) {
        pos.Int == 0;
    }
    multi method EXISTS-POS(Any:D: Any:U \pos) {
        die "Cannot use '{pos.^name}' as an index";
    }

    method at_pos(|c) is rw is nodal {
        DEPRECATED('AT-POS',|<2015.03 2015.09>);
        self.AT-POS(|c);
    }

    proto method AT-POS(|) is nodal {*}
    multi method AT-POS(Any:U \SELF: int \pos) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Array.new);
                 SELF.BIND-POS(pos, $v) });
        $v
    }
    multi method AT-POS(Any:U \SELF: Int:D \pos) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Array.new);
                 SELF.BIND-POS(nqp::unbox_i(pos), $v) });
        $v
    }
    multi method AT-POS(Any:U: Num:D \pos) is rw {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
    }
    multi method AT-POS(Any:U: Any:D \pos) is rw {
        self.AT-POS(nqp::unbox_i(pos.Int));
    }

    multi method AT-POS(Any:D: int \pos) is rw {
        fail X::OutOfRange.new(:what<Index>, :got(pos), :range<0..0>)
          unless nqp::not_i(pos);
        self;
    }
    multi method AT-POS(Any:D: Int:D \pos) is rw {
        fail X::OutOfRange.new(:what<Index>, :got(pos), :range<0..0>)
          if pos != 0;
        self;
    }
    multi method AT-POS(Any:D: Num:D \pos) is rw {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
    }
    multi method AT-POS(Any:D: Any:D \pos) is rw {
        self.AT-POS(nqp::unbox_i(pos.Int));
    }

    multi method AT-POS(Any:   Any:U \pos) is rw {
        die "Cannot use '{pos.^name}' as an index";
    }

    method bind_pos(|c) is rw is nodal {
        DEPRECATED('BIND-POS',|<2015.03 2015.09>);
        self.BIND-POS(|c);
    }

    method assign_pos(|c) is nodal {
        DEPRECATED('ASSIGN-POS',|<2015.03 2015.09>);
        self.ASSIGN-POS(|c);
    }

    proto method ASSIGN-POS(|) is nodal { * }
    multi method ASSIGN-POS(Any:U \SELF: \pos, Mu \assignee) {
       SELF.AT-POS(pos) = assignee;                     # defer < 0 check
    }

    multi method ASSIGN-POS(Any:D: int \pos, Mu \assignee) {
        self.AT-POS(pos) = assignee;                    # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Int:D \pos, Mu \assignee) {
        self.AT-POS(pos) = assignee;                    # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Num:D \pos, Mu \assignee) {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int)) = assignee;  # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Any:D \pos, Mu \assignee) {
        self.AT-POS(nqp::unbox_i(pos.Int)) = assignee;  # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Any:U \pos, Mu \assignee) {
        die "Cannot use '{pos.^name}' as an index";
    }

    method all() is nodal { Junction.new(self.list, :type<all>) }
    method any() is nodal { Junction.new(self.list, :type<any>) }
    method one() is nodal { Junction.new(self.list, :type<one>) }
    method none() is nodal { Junction.new(self.list, :type<none>) }

    method at_key(|c) is rw is nodal {
        DEPRECATED('AT-KEY',|<2015.03 2015.09>);
        self.AT-KEY(|c);
    }

    # internals
    proto method AT-KEY(|) is nodal { * }
    multi method AT-KEY(Any:D: $key) is rw {
        fail "postcircumfix:<\{ \}> not defined for type {self.WHAT.perl}";
    }
    multi method AT-KEY(Any:U \SELF: $key) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Hash.new);
                 SELF.BIND-KEY($key, $v) });
        $v
    }

    method bind_key(|c) is rw is nodal {
        DEPRECATED('BIND-KEY',|<2015.03 2015.09>);
        self.BIND-KEY(|c);
    }

    proto method BIND-KEY(|) is nodal { * }
    multi method BIND-KEY(Any:D: \k, \v) is rw {
        fail X::Bind.new(target => self.^name);
    }
    multi method BIND-KEY(Any:U \SELF: $key, $BIND ) is rw {
        SELF = Hash.new;
        SELF.BIND-KEY($key, $BIND);
        $BIND
    }

    method assign_key(|c) is nodal {
        DEPRECATED('ASSIGN-KEY',|<2015.03 2015.09>);
        self.ASSIGN-KEY(|c);
    }

    proto method ASSIGN-KEY(|) is nodal { * }
    multi method ASSIGN-KEY(\SELF: \key, Mu \assignee) {
        SELF.AT-KEY(key) = assignee;
    }

    # XXX GLR review these
    method FLATTENABLE_LIST() is nodal {
        my $list := self.list;
        nqp::findmethod($list, 'FLATTENABLE_LIST')($list);
    }
    method FLATTENABLE_HASH() is nodal { nqp::hash() }

    # XXX GLR do these really need to force a list?
    method Set()     is nodal {     Set.new-from-pairs(self.list) }
    method SetHash() is nodal { SetHash.new-from-pairs(self.list) }
    method Bag()     is nodal {     Bag.new-from-pairs(self.list) }
    method BagHash() is nodal { BagHash.new-from-pairs(self.list) }
    method Mix()     is nodal {     Mix.new-from-pairs(self.list) }
    method MixHash() is nodal { MixHash.new-from-pairs(self.list) }
    method Supply() is nodal { self.list.Supply }

    method print-nl() { self.print("\n") }
}
Metamodel::ClassHOW.exclude_parent(Any);

# builtin ops
proto sub infix:<===>(Mu $?, Mu $?) is pure { * }
multi sub infix:<===>($?)    { Bool::True }
multi sub infix:<===>($a, $b) {
    nqp::p6bool(nqp::iseq_s(nqp::unbox_s($a.WHICH), nqp::unbox_s($b.WHICH)))
}

proto sub infix:<before>(Mu $, Mu $?)  is pure { * }
multi sub infix:<before>($?)      { Bool::True }
multi sub infix:<before>(\a, \b)   { (a cmp b) < 0 }

proto sub infix:<after>(Mu $, Mu $?) is pure { * }
multi sub infix:<after>($x?)       { Bool::True }
multi sub infix:<after>(\a, \b)    { (a cmp b) > 0 }

# XXX: should really be '$a is rw' (no \) in the next four operators
proto prefix:<++>(|)             { * }
multi prefix:<++>(Mu:D \a is rw) { a = a.succ }
multi prefix:<++>(Mu:U \a is rw) { a = 1 }
proto prefix:<-->(|)             { * }
multi prefix:<-->(Mu:D \a is rw) { a = a.pred }
multi prefix:<-->(Mu:U \a is rw) { a = -1 }

proto postfix:<++>(|)             { * }
multi postfix:<++>(Mu:D \a is rw) { my $b = a; a = a.succ; $b }
multi postfix:<++>(Mu:U \a is rw) { a = 1; 0 }
proto postfix:<-->(|)             { * }
multi postfix:<-->(Mu:D \a is rw) { my $b = a; a = a.pred; $b }
multi postfix:<-->(Mu:U \a is rw) { a = -1; 0 }

proto sub pick(|) { * }
multi sub pick($n, @values) { @values.pick($n) }
multi sub pick($n, *@values) { @values.pick($n) }

proto sub roll(|) { * }
multi sub roll($n, @values) { @values.roll($n) }
multi sub roll($n, *@values) { @values.roll($n) }

proto sub keys(|) { * }
multi sub keys($x) { $x.keys }

proto sub values(|) { * }
multi sub values($x) { $x.values }

proto sub pairs(|) { * }
multi sub pairs($x) { $x.pairs }

proto sub kv(|) { * }
multi sub kv($x) { $x.kv }

proto sub elems(|) is nodal { * }
multi sub elems($a) { $a.elems }

proto sub end(|) { * }
multi sub end($a) { $a.end }

sub classify( $test, *@items, *%named ) {
    if %named.EXISTS-KEY("into") {
        my $into := %named.DELETE-KEY("into");
        ( $into // $into.new).classify-list($test, @items, |%named);
    }
    else {
        Hash.^parameterize(Any,Any).new.classify-list($test, @items, |%named);
    }
}
sub categorize( $test, *@items, *%named ) {
    if %named.EXISTS-KEY("into") {
        my $into := %named.DELETE-KEY("into");
        ( $into // $into.new).categorize-list($test, @items, |%named);
    }
    else {
        Hash.^parameterize(Any,Any).new.categorize-list($test, @items, |%named);
    }
}

proto sub item(|) is pure { * }
multi sub item(\x)    { my $ = x }
multi sub item(|c)    { my $ = c.list }
multi sub item(Mu $a) { $a }

sub RWPAIR(\k, \v) {   # internal fast pair creation
    my \p := nqp::create(Pair);
    nqp::bindattr(p, Enum, '$!key', k);
    nqp::bindattr(p, Enum, '$!value', v);
    p
}

sub SLICE_HUH(\SELF, @nogo, %d, %adv) {
    @nogo.unshift('delete')  # recover any :delete if necessary
      if @nogo && @nogo[0] ne 'delete' && %adv.EXISTS-KEY('delete');
    for <delete exists kv p k v> -> $valid { # check all valid params
        if nqp::existskey(%d,nqp::unbox_s($valid)) {
            nqp::deletekey(%d,nqp::unbox_s($valid));
            @nogo.push($valid);
        }
    }

    fail X::Adverb::Slice.new(
      :what(try { SELF.VAR.name } // SELF.WHAT.perl),
      :unexpected(%d.keys.sort),
      :nogo(@nogo.sort),
    );
} #SLICE_HUH

sub DELETEKEY(Mu \d, str $key) {
    if nqp::existskey(d,$key) {
        my Mu $value := nqp::atkey(d,$key);
        nqp::deletekey(d,$key);
        $value;
    }
    else {
        Mu;
    }
} #DELETEKEY

sub dd(|) {
    my Mu $args := nqp::p6argvmarray();
    while $args {
        my $var  := nqp::shift($args);
        my $name := $var.VAR.?name;
        my $what := $var.?infinite
          ?? $var[^10].perl.chop ~ "...Inf)"
          !! $var.perl;
        note $name ?? "$name = $what" !! $what;
    }
    return
}

# vim: ft=perl6 expandtab sw=4

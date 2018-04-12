class C inherits B {
	a : Int;
	b : Bool;
	init(x : Int, y : Bool) : C {
           {
		a <- x;
		b <- y;
		self;
           }
	};
};

class B inherits A {

};

Class A inherits C {

};

Class Main {
	main():C {
	  (new C).init(1,true)
	};
};

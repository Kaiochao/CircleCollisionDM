// A 2D vector datum for BYOND projects.

vector
	var x, y

	New(X, Y)
		x = X || 0
		y = Y || 0

	proc/Add(vector:V)
		return new type (x + V.x, y + V.y)

	proc/Subtract(vector:V)
		return new type (x - V.x, y - V.y)

	proc/Multiply(S as num)
		return new type (S * x, S * y)

	proc/Divide(S as num)
		return new type (x / S, y / S)

	proc/Dot(vector:V)
		return x * V.x + y * V.y

	proc/Cross(vector:V)
		return x * V.y - y * V.x

	proc/Length()
		return sqrt(Dot(src))

	proc/Unit()
		return Divide(Length())


point
	parent_type = /vector

	New(X, Y)
		if(istype(X, /vector))
			var vector/V = X
			Y = V.y
			X = V.x
		..(X, Y)

	proc/VectorTo(point:B)
		return B.Subtract(src)
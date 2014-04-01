var obj/circle:a
var obj/circle:b
var restitution = 1

world
	name = "Circle Collision Demo"
	maxx = 30
	maxy = 30
	view = 15
	fps = 60

	New()
		var max_px = (maxx - 1) * 32
		var max_py = (maxy - 1) * 32

		var circles[50]

		for(var/n in 1 to circles.len)
			var obj/circle:c = new (
				Position = new /point (rand(max_px), rand(max_py)),
				Velocity = new /vector (randn(-2, 2), randn(-2, 2)))
			c.color = rgb(rand(255), rand(255), rand(255))
			c.radius = randn(24, 48)
			c.mass = c.radius
			circles[n] = c

		spawn(10) for()
			sleep tick_lag

			// move each circle
			for(var/obj/circle:c in circles)
				c.position.x += c.velocity.x
				c.position.y += c.velocity.y
				c.EdgeCheck()

			// resolve collisions
			for(var/i in 1 to circles.len - 1)
				for(var/j in i + 1 to circles.len)
					resolve_circles(circles[i], circles[j])

			// update the appearance of each circle
			for(var/obj/circle:c in circles)
				c.transform = c.GetTransform()

			// update the title of client windows
			for(var/client/c)
				if(c.key)
					winset(c, "default", "title=\"[name] ([cpu]%)\"")

turf
	icon = 'square.dmi'

obj/circle
	icon = 'big circle.dmi'

	var mass = 1
	var radius = 16
	var point:position
	var vector:velocity

	New(point:Position, vector:Velocity)
		position = Position || new
		velocity = Velocity || new

	proc/GetTransform()
		loc = locate(1, 1, 1)
		var matrix/m = new
		m.Scale((2 * (radius + 1)) / 256)
		m.Translate((32 - 256) / 2 - 16)
		m.Translate((position.x), (position.y))
		return m

	proc/EdgeCheck()
		if(position.x < radius)
			position.x = radius
			velocity.x = abs(velocity.x) * restitution

		if(position.x > world.maxx * 32 - radius)
			position.x = world.maxx * 32 - radius
			velocity.x = -abs(velocity.x) * restitution

		if(position.y < radius)
			position.y = radius
			velocity.y = abs(velocity.y) * restitution

		if(position.y > world.maxy * 32 - radius)
			position.y = world.maxy * 32 - radius
			velocity.y = -abs(velocity.y) * restitution


proc/lerp(a, b, c) return a + (b - a) * c
proc/randn(a, b) return lerp(a, b, rand())

proc/resolve_circles(obj/circle:A, obj/circle:B)
	var dx = B.position.x - A.position.x
	var dy = B.position.y - A.position.y
	var r = A.radius + B.radius
	if(dx * dx + dy * dy > r * r) return

	// get the mtd
	var vector:delta = A.position.Subtract(B.position);
	var d = delta.Length();
	if(d == 0) return

	// minimum translation distance to push balls apart after intersecting
	var vector:mtd = delta.Multiply(((A.radius + B.radius) - d) / d);

	if(mtd.Length() == 0) return

	// resolve intersection --
	// inverse mass quantities
	var im1 = 1 / A.mass;
	var im2 = 1 / B.mass;

	// push-pull them apart based off their mass
	A.position = A.position.Add(mtd.Multiply(im1 / (im1 + im2)));
	B.position = B.position.Subtract(mtd.Multiply(im2 / (im1 + im2)));

	// impact speed
	var vector:v = A.velocity.Subtract(B.velocity);
	var vector:mtdu = mtd.Unit();
	var vn = v.Dot(mtdu);

	// sphere intersecting but moving away from each other already
	if (vn > 0) return;

	// collision impulse
	var i = (-(1 + restitution) * vn) / (im1 + im2);
	var vector:impulse = mtdu.Multiply(i);

	// change in momentum
	A.velocity = A.velocity.Add(impulse.Multiply(im1));
	B.velocity = B.velocity.Subtract(impulse.Multiply(im2));
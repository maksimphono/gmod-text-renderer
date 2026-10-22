function sqr(x)
	return x * x
end

function distance(p1, p2)
	return math.abs(math.sqrt(sqr(p1.x - p2.x) + sqr(p1.y - p2.y) + sqr(p1.z - p2.z)))
end

function vecLen(v1, v2)
	return distance(v1, Vector(0,0,0))
end

function vecMul(v1, v2)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end
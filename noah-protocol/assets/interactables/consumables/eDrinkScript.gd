extends InteractableDynamic

var full : bool = true

func interact(body):
	if full:
		if body.has_method("consume"):
			body.consume("eDrink")
			full = false

	
install:
	pixlet render status.star
	pixlet push --installation-id status strictly-evident-lucky-hairtail-4be status.webp

test:
	pixlet serve hello_world.star

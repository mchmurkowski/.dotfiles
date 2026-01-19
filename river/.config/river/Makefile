init: river.fnl
	fennel --compile $< > $@
	sed -i '1s/^/#!\/usr\/bin\/lua5.4\n/' init
	chmod +x init

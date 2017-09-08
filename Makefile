all: 
	cd src ; \
	zip ../VPN-Control.alfredworkflow . -r --exclude=*.DS_Store*

clean:
	rm VPN-Control.alfredworkflow

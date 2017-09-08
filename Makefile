all: 
	cd src ; \
	zip ../VPN-toggle.alfredworkflow . -r --exclude=*.DS_Store*

clean:
	rm VPN-toggle.alfredworkflow

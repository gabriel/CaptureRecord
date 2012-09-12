
docs:
	rm -rf Documentation/output
	appledoc -o Documentation/output -p CaptureRecord -v 0.1.0 -c "CaptureRecord" --company-id "me.rel" --warn-undocumented-object --warn-undocumented-member --warn-empty-description --warn-unknown-directive --warn-invalid-crossref --warn-missing-arg --no-repeat-first-par --keep-intermediate-files --ignore CaptureRecord/CRUIButton.h --docset-feed-url http://gabriel.github.com/Cap/publish/%DOCSETATOMFILENAME --docset-package-url http://gabriel.github.com/Cap/publish/%DOCSETPACKAGEFILENAME --index-desc Documentation/index.txt --verbose=3 --create-html --create-docset --publish-docset --exit-threshold 2 CaptureRecord/
	cp -R Documentation/output/html/ Site/api/


gh-pages: docs
	rm -rf ../doctmp
	mkdir -p ../doctmp
	cp -R Documentation/output/html/* ../doctmp
	cp -R Documentation/output/publish ../doctmp/publish
	rm -rf Documentation/output/*
	git checkout gh-pages
	git symbolic-ref HEAD refs/heads/gh-pages
	rm .git/index
	git clean -fdx
	cp -R ../doctmp/* .
	git add .
	git commit -a -m 'Updating docs' && git push origin gh-pages
	git checkout master

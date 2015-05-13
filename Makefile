all:
	@cat Makefile | grep : | grep -v PHONY | grep -v @ | sed 's/:/ /' | awk '{print $$1}' | sort

#-------------------------------------------------------------------------------

.PHONY: install
install:
	bundle install

.PHONY: test
test: install
	ruby ./test_helper.rb

#-------------------------------------------------------------------------------

.PHONY: docs
docs: install
	yard

.PHONY: pushdocs
pushdocs: docs
	rm -Rf /tmp/gh-pages
	git clone git@github.com:wepay/Ruby-SDK.git --branch gh-pages --single-branch /tmp/gh-pages
	cp -Rf ./doc/ /tmp/gh-pages/
	cd /tmp/gh-pages/ && git add . && git commit -a -m "Automated commit on $$(date)" && git push origin gh-pages

#-------------------------------------------------------------------------------

.PHONY: gem
gem: version
	@sed "s/@@version@@/$$(cat VERSION)/" < ./build/wepay.gemtmpl > ./wepay.gemspec
	@cat ./wepay.gemspec | sed "s/@@date@@/$$(date "+%Y-%m-%d")/" > ./wepay.gemspec
	gem build wepay.gemspec

.PHONY: pushgem
pushgem: gem
	gem push wepay-$$(cat ./VERSION).gem

#-------------------------------------------------------------------------------

.PHONY: tag
tag:
	@ if [ $$(git status -s -uall | wc -l) != 0 ]; then echo 'ERROR: Git workspace must be clean.'; exit 1; fi;

	@echo "This release will be tagged as: $$(cat ./VERSION)"
	@echo "This version should match your gem. If it doesn't, re-run 'make gem'."
	@echo "---------------------------------------------------------------------"
	@read -p "Press any key to continue, or press Control+C to cancel. " x;

	@sed "s/@@version@@/$$(cat VERSION)/" < ./build/readme.tmpl > ./README.md
	keybase dir sign
	git add .
	git commit -a -m "Cryptographically signed the $$(cat ./VERSION) release."
	git tag $$(cat ./VERSION)

#-------------------------------------------------------------------------------

.PHONY: version
version:
	@echo "Current version: $$(cat ./VERSION)"
	@read -p "Enter new version number: " nv; \
	printf "$$nv" > ./VERSION

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm *.gem
	rm *.gemspec

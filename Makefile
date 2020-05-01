#   Copyright (C) 2020 Gildásio Júnior
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Init variables
#
# Set init variables to start up
# Read the docs first
# If you have any questions, please contact me
#
URL=https:\/\/gildasio.gitlab.io\/make-txt-site\/
AUTHOR=gildasio
SITE=Make TXT Site

PREFIX=public/
PUBLIC_INDEX=index
HIDDEN_INDEX=priv
HIDDEN_PATTERN=priv_
## Init variables end

LINE_PUBLIC_TXT := $(shell grep -n '{{content}}' template/$(PUBLIC_INDEX).txt | cut -d: -f1)
LINE_PUBLIC_HTML := $(shell grep -n '{{content}}' template/$(PUBLIC_INDEX).html | cut -d: -f1)
LINE_HIDDEN_TXT := $(shell grep -n '{{content}}' template/$(HIDDEN_INDEX).txt | cut -d: -f1)
LINE_HIDDEN_HTML := $(shell grep -n '{{content}}' template/$(HIDDEN_INDEX).html | cut -d: -f1)

DATE := $(shell date +%d-%m-%Y)
DATE_FEED := $(shell date +%FT%TZ)

FEED_POSTS := $(shell find $(PREFIX) -type f -name '*.txt' -printf '%T@ %p\n' | sort | fgrep -v $(PUBLIC_INDEX) | fgrep -v $(HIDDEN_INDEX) | fgrep -v atom.xml | tail -5 | cut -d ' ' -f 2)
HIDDEN_FEED_POSTS := $(shell find $(PREFIX) -type f -name '*.txt' -printf '%T@ %p\n' | sort | fgrep -v $(PUBLIC_INDEX) | fgrep -v $(HIDDEN_INDEX). | fgrep -v atom.xml | tail -5 | cut -d ' ' -f 2)

.PHONY: list clean clean_all

help:
		@echo 'Make TXT Site - site as txt files'
		@echo '                github.com/gildasio/make-txt-site'
		@echo ''
		@echo 'Usage:'
		@echo -e '\tmake help		show this menu'
		@echo -e '\tmake all		compile all files'
		@echo -e '\tmake list		create file lists'
		@echo -e '\tmake posts		create public posts index files'
		@echo -e '\tmake hidden		create hidden posts index files'
		@echo -e '\tmake clean		clean file lists (make c, for shorten)'
		@echo -e '\tmake clean_all		clean all generated files (make ca)'
		@echo -e '\tmake post <file>	copy template post to $PREFIX<filename>'
		@echo -e '\tmake sign <file>	sign $PREFIX<filename> file using gpg'
		@echo -e '\tmake feed		generate atom feed file (public and private)'

all: posts hidden feed

$(PUBLIC_INDEX):
		sed 's/{{content}}/$$ tree -tr/' template/$(PUBLIC_INDEX).txt > $(PREFIX)$(PUBLIC_INDEX).txt
		sed 's/{{content}}/$$ tree -tr/' template/$(PUBLIC_INDEX).html > $(PREFIX)$(PUBLIC_INDEX).html

$(HIDDEN_INDEX):
		sed 's/{{content}}/$$ tree -tr/' template/$(HIDDEN_INDEX).txt > $(PREFIX)$(HIDDEN_INDEX).txt
		sed 's/{{content}}/$$ tree -tr/' template/$(HIDDEN_INDEX).html > $(PREFIX)$(HIDDEN_INDEX).html

list:
		echo '.' > output/public
		echo '.' > output/hidden
		tree -tr $(PREFIX) -I imgs | tail -n +2 | head -n -2 | grep -v '$(PUBLIC_INDEX)' | grep -v '$(HIDDEN_INDEX)\.' | grep -v '$(HIDDEN_PATTERN)' >> output/public
		tree -tr $(PREFIX) -I imgs | tail -n +2 | head -n -2 | grep -v '$(PUBLIC_INDEX)' | grep -v '$(HIDDEN_INDEX)\.' >> output/hidden

posts: $(PUBLIC_INDEX) list
		sed -i -e "${LINE_PUBLIC_TXT}r output/public" $(PREFIX)$(PUBLIC_INDEX).txt
		sed -i -e "${LINE_PUBLIC_HTML}r output/public" $(PREFIX)$(PUBLIC_INDEX).html

hidden: $(HIDDEN_INDEX) list
		sed -i -e "${LINE_HIDDEN_TXT}r output/hidden" $(PREFIX)$(HIDDEN_INDEX).txt
		sed -i -e "${LINE_HIDDEN_HTML}r output/hidden" $(PREFIX)$(HIDDEN_INDEX).html

c: clean
clean:
		rm -f output/*

ca: clean_all
clean_all: clean
		rm -f $(PREFIX)$(PUBLIC_INDEX).txt $(PREFIX)$(PUBLIC_INDEX).html
		rm -f $(PREFIX)$(HIDDEN_INDEX).txt $(PREFIX)$(HIDDEN_INDEX).html
		rm -f $(PREFIX)*atom.xml

post:
		sed "s/{{date}}/${DATE}/" template/post.txt > $(PREFIX)$(filter-out $@,$(MAKECMDGOALS))
		$(EDITOR) $(PREFIX)$(filter-out $@,$(MAKECMDGOALS))

sign:
		gpg -a --sign $(PREFIX)$(filter-out $@,$(MAKECMDGOALS))
		cat $(PREFIX)$(filter-out $@,$(MAKECMDGOALS)).asc >> $(PREFIX)$(filter-out $@,$(MAKECMDGOALS))
		rm $(PREFIX)$(filter-out $@,$(MAKECMDGOALS)).asc
		gpg --verify $(PREFIX)$(filter-out $@,$(MAKECMDGOALS))

%:
		@:

feed: public_feed hidden_feed

public_feed:
		cp template/atom.xml $(PREFIX)atom.xml
		sed -i 's/{{site}}/${SITE}/' $(PREFIX)atom.xml
		sed -i 's/{{url}}/${URL}/' $(PREFIX)atom.xml
		sed -i 's/{{self}}/${URL}atom.xml/' $(PREFIX)atom.xml
		sed -i 's/{{date}}/${DATE_FEED}/' $(PREFIX)atom.xml
		sed -i 's/{{author}}/${AUTHOR}/' $(PREFIX)atom.xml
		$(foreach feed_post,$(FEED_POSTS),./feed.sh $(feed_post) $(URL) $(PREFIX)atom.xml;)
		echo '</feed>' >> $(PREFIX)atom.xml

hidden_feed:
		cp template/atom.xml $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		sed -i 's/{{site}}/${SITE}/' $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		sed -i 's/{{url}}/${URL}/' $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		sed -i 's/{{self}}/${URL}$(HIDDEN_PATTERN)atom.xml/' $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		sed -i 's/{{date}}/${DATE_FEED}/' $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		sed -i 's/{{author}}/${AUTHOR}/' $(PREFIX)$(HIDDEN_PATTERN)atom.xml
		$(foreach feed_post,$(HIDDEN_FEED_POSTS),./feed.sh $(feed_post) $(URL) $(PREFIX)$(HIDDEN_PATTERN)atom.xml;)
		echo '</feed>' >> $(PREFIX)$(HIDDEN_PATTERN)atom.xml

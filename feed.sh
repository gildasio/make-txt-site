#!/usr/bin/env bash
#
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
#
#	Must receive three arguments:
#		$1: Filename (with path) to read and get content to put in Atom Feed
#		$2: Site base URL
#		$3: Filename to put content in
#
#	And generate entry element to put in an Atom Feed file
#

TITLE=$(echo $1 | cut -d'/' -f 2-)
URL=$2$TITLE
DATE=$(grep 'Post date:' $1 | cut -d' ' -f 3)
DATE=$(find -wholename ./$1 -printf '%TY-%Tm-%TdT%TH:%TM:%TS.Z' | cut -d'.' -f 1,3 | tr -d '.')
CONTENT=$(cat $1)

echo $URL

cat <<EOF >> $3
<entry>
  <title>${TITLE}</title>
  <link href="${URL}" />
  <updated>${DATE}</updated>
  <id>${URL}</id>
  <content type="text">${CONTENT}</content>
</entry>
EOF

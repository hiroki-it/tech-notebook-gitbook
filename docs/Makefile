replace-md:
	find ./* -name "*.md" -type f | xargs sed -i '' -e 's/，/、/g' -e 's/．/。/g'

build: replace-md
	gitbook build . docs
	find ./* -name "*.html" -type f | xargs sed -i '' 's/検索すると入力/検索/g'

serve: replace-md
	gitbook serve . docs
	find ./* -name "*.html" -type f | xargs sed -i '' 's/検索すると入力/検索/g'

commit-note:
	git checkout develop
	git add public
	git commit -m "update ノートを更新した．"

commit-note-static: build
	git checkout develop
	git add docs
	git commit -m "update 静的ファイルを更新した．"

rm-static:
	rm -Rf docs

commit-push-all: commit-note-static
	git push
	git checkout main && git merge develop && git push
	git checkout develop

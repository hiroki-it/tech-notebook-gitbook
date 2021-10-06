build:
	gitbook build . docs

serve:
	gitbook serve . docs

replace:
	find ./* -name "*.html" -type f | xargs sed -i '' 's/検索すると入力/検索/g'

commit-note:
	git checkout develop
	git add public
	git commit -m "update ノートを更新した．"

commit-static: build replace
	git checkout develop
	git add docs
	git commit -m "update 静的ファイルを更新した．"

rm-static:
	rm -Rf docs

commit-push-all: commit-note commit-static
	git push
	git checkout main && git merge develop && git push
	git checkout develop

install:
	gitbook install

build:
	gitbook build . docs
	sed -i '' 's/検索すると入力/検索/g' docs/*.html docs/**/*.html

serve:
	gitbook serve . docs
	sed -i '' 's/検索すると入力/検索/g' docs/*.html docs/**/*.html

commit-note:
	git add public
	git commit -m "update ノートを更新した．"

commit-static: build
	git add docs
	git commit -m "update 静的ファイルを更新した．"

rm-static:
	rm -Rf docs

commit-push-all: commit-note commit-static
	git checkout develop && git push
	git checkout main && git merge develop && git push
	git checkout develop

build:
	gitbook build . docs

build-commit-static:
	gitbook build . docs
	git add docs
	git commit -m "update 静的ファイルを更新した．"

commit-note:
	git add public
	git commit -m "update ノートを更新した．"

serve:
	gitbook serve . docs

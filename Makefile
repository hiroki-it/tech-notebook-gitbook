build:
	gitbook build . docs
	sed -i '' 's/検索すると入力/検索/g' docs/*.html docs/**/*.html

serve:
	gitbook serve . docs
	sed -i '' 's/検索すると入力/検索/g' docs/*.html docs/**/*.html

commit-static: build
	git add docs
	git commit -m "update 静的ファイルを更新した．"

commit-note:
	git add public
	git commit -m "update ノートを更新した．"


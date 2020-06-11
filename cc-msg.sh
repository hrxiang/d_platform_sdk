echo '♻️  enter the message that to be commit:'
read msg
echo '\n'
git add .
echo 'added all...'
echo '\n'
git commit -m ${msg}
echo '\n'
echo 'msg commited...'
echo '\n'
git push
echo '\n'
echo '👌done...'

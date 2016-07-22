#!/bin/zsh

cd /home/pi/git/lo21-projet
#git pull origin master
rm /tmp/output.html
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="fr">
<head>
  <meta http-equiv="content-type" content="text/html;charset=utf-8" />
</head>
<body>
    <p>Coucou, je suis un email automatique destiné à te faire chier. Quelqu'\''un vient de faire un commit, voyons les stats...</p>
    <h1>Voici les stats pour le projet LO21</h1>
    <pre>' > /tmp/output.html
git ls-tree -r -z --name-only HEAD -- **/*.(cpp|h) | xargs -0 -n1 git blame --line-porcelain HEAD |grep  '^author '|sort|uniq -c|sort -nr| sed 's/author/lignes (dans un fichier .cpp ou .h) écrites par/' >> /tmp/output.html
echo '</pre><h3>Au boulot, fegnasses ! &lt;3</h3>
</body>
</html>' >> /tmp/output.html
echo "yes" | /home/pi/git/python-mailer/pymailer.py -s /tmp/output.html /home/pi/git/python-mailer/recipients.csv 'Stats LO21'                              

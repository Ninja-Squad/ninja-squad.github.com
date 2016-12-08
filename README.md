# Le blog de Ninja Squad

## Run with Docker

Run boot2docker (check that the port 4000 is open on your VM) and launch:

    ./serve.sh

## Run with Ruby

Install Ruby 2.0+.
Install Github pages :

    gem install github-pages

Run the blog :

    jekyll serve --watch --incremental --future

## Principe de fonctionnement

Le blog est basé sur <a href="http://jekyllbootstrap.com">Jekyll-Bootstrap</a>.
Suivez ce lien pour avoir une documentation plus complète. Le blog est hébergé
directement par github, qui regénère les pages du blog à chaque push sur la branche master.

En deux mots, le principe : on crée des posts en créant des fichiers sur le modèle de ceux existants.
Le modèle du nom de fichier et de l'en-tête doivent être respectés. La syntaxe des posts est markdown.
Pour créer un post, suivre donc les étapes suivantes:

 - créer un fichier avec le bon nom, le bon en-tête, et le contenu en Markdown
 - sauvegarder ce fichier en UTF-8
 - faire tourner jekyll en local pour voir si tout va bien
 - consulter le post sur http://localhost:4000/
 - faire les corrections nécessaires
 - committer et pusher: quelques secondes après, le blog est regénéré par github

Bien sûr on peut faire ça dans une branche, et faire une pull-request afin de faire relire le post
par un collègue avant de le publier.

## Syntaxe des posts

La syntaxe est Markdown, qui est un sur-ensemble de HTML. Twitter-bootstrap est utilisé pour le CSS.
Il y a cependant quelques gotchas:

 - Si un item d'une liste commence par un lien, le moteur markdown bugge, et ne génère aucun texte pour
 cet item. Le truc est de faire précéder le lien par un caractère blanc HTML: `&nbsp;` ou `&#x20;`.

         - &#x20;<a href="http://oracle.com">Oracle</a> est une grosse boîte
         - Les blocs HTML vides sont mal gérés. Il faut au moins mettre un espace dedans.

 - Google prettify est utilisé pour colorer syntaxiquement le code. La détection du langage est automatique.
 Tous les blocs `<pre>...</pre>` sont automatiquement prettifiés (y compris et surtout ceux générés par Markdown).
 Si vous voulez un bloc de code sans prettification, utilisez un bloc HTML avec la classe `raw`:

        <pre class="raw">
            System.out.println("Ce code n'est pas prettifié");
        </pre>

## Installation de Jekyll en local.

### Unix

Pour les OS Unix, suivre les instructions dans le <a href="https://github.com/mojombo/jekyll/wiki/install">README de Jekyll</a>.

### Windows

Pour Windows, suivre les instructions sur
<a href="http://forresst.github.com/2012/03/20/Installer-Jekyll-Sous-Windows/">cette page</a> (étapes I et II).
La partie Python n'est pas nécessaire, puisque nous utilisons Google prettify pour la coloration syntaxique.

Une installation pré-configurée, après avoir suivi toutes ces étapes, est disponible
sur <a href="https://docs.google.com/a/ninja-squad.com/open?id=0B0FLWwufPzrTbUhVNWlOQzZoREk">Google Drive</a>.
Pour l'utiliser, il suffit de télécharger le zip, l'extraire dans un dossier (par exemple `D:\tools`),
et d'ajouter son répertoire bin (par exemple `D:\tools\winjekyll\bin`) à la variable d'environnement `PATH`.

Avant de lancer jekyll, il faut bien s'assurer d'avoir exécuté les commandes suivantes:

    set LC_ALL=en_US.UTF-8
    set LANG=en_US.UTF-8

On peut ensuite lancer Jekyll en tapant la commande suivante, à la racine du projet :

    jekyll serve --future

Ou, pour plus de diagnostic en cas d'erreur (par exemple, si on a oublié de taper les commandes ci-dessus, et que rien
ne se produit au lancement de jekyll):

    jekyll --no-auto --server

L'alternative est de lancer la commande `blog.cmd`, à la racine du projet, qui lance les 3 commandes nécessaires.

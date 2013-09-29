---
layout: post
title: Git config - les options indispensables
author: [cexbrayat]
tags: [git]
canonical: http://hypedrivendev.wordpress.com/2013/09/30/git-config-les-options-indispensables
---

Si vous utilisez Git, vous connaissez probablement la commande `git config` qui permet de paramétrer Git. Vous savez peut-être qu'il existe 3 niveaux possibles de stockage de ces paramètres&nbsp;:

- system (tous les utilisateurs)
- global (pour votre utilisateur)
- local (pour votre projet courant)

Si un paramètre est défini localement et globalement avec des valeurs différentes, ce sera la valeur locale qui sera utilisée (le niveau le plus bas surcharge les niveaux supérieurs).

Il est possible d'afficher sa configuration avec&nbsp;:

    git config --list

On peut ajouter une valeur très simplement, par exemple mon `user.name` (utilisé pour l'auteur des commits)&nbsp;:

    git config --global user.name cexbrayat

Et l'on peut supprimer une valeur avec `--unset`&nbsp;:

    git config --unset user.name

Savez-vous que l'on peut également définir des alias de commande&nbsp;? Par exemple, j'utilise souvent l'alias `lg` pour une version de `log` améliorée&nbsp;:

    git config alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

Mais revenons à nos paramétrages. La documentation de Git est très riche et il n'est pas simple de savoir quelles options peuvent être utiles. Le fichier *.gitconfig* dans votre *home* contient tous vos paramétrages (lorsque vous les avez ajouté en global). Ce fichier regroupe les clés par section. Par exemple `user.name` et `user.email` sont regroupées dans une section `[user]`. Vous allez voir, rien de compliqué&nbsp;!
<br/><br/>

Voici les paramètres que j'aime utiliser&nbsp;:

    [user]
        email = cedric@ninja-squad.com
        name = cexbrayat

Ces deux paramètres sont nécessaires pour faire un commit et apparaîtront dans le log de vos collègues, à compléter dès l'installation donc&nbsp;!
<br/><br/>

    [core]
        editor = vim
        pager = less

La section core contient beaucoup d'options possibles. Parmi elles, `editor` vous permet de choisir quel éditeur de texte sera utilisé (j'aime bien vim, si si je vous assure, mais vous pouvez très bien mettre SublimeText par exemple, avec `subl -w`), idem pour le pager utilisé par Git (pour afficher le log par exemple). Il faut savoir que Git pagine dès que l'affichage ne rentre pas dans votre écran&nbsp;: certains détestent ça et préfèrent utiliser `cat` plutôt.
<br/><br/>

    [alias]
        lg = log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
        wdiff = diff --word-diff

Cette section contient tous les alias que vous ajouterez. Comme j'utilise oh-my-zsh et son plugin Git, j'ai déjà beaucoup d'alias disponibles (par exemple `gc` pour `git commit`). On retrouve donc `lg` pour un meilleur log et `wdiff` pour un diff en mode *mot* et pas *ligne*. Exemple avec `git diff`&nbsp;:

    -:author:    Ninja Squad
    +:author:    Ninja Squad Team
    
Un seul mot ajouté, mais Git considère que la ligne entière est changée. Alors qu'avec `git wdiff`&nbsp;:

    :author:    Ninja Squad{+ Team+}

Il reconnaît bien le seul ajout de mot sur la ligne&nbsp;!
<br/><br/>

    [color]
        ui = auto

Git est tout de suite plus convivial en ligne de commande avec un peu de couleur. Il est quasiment possible de définir pour chaque commande quelle couleur vous voulez, mais le plus simple est d'utiliser la clé `color.ui` qui donne une valeur par défaut à toutes les commandes. A vous les branches en couleur, le log en couleur, le diff en couleur...
<br/><br/>

    [credential]
        helper = osxkeychain

Si vous utilisez un repo distant protégé par mot de passe (à tout hasard Github), il est possible de stocker votre mot de passe pour ne pas avoir à le saisir à chaque fois. Sur MacOS, le keychain se charge de le stocker pour vous.
<br/><br/>

    [clean]
        requireForce = false

Git possède une commande `clean` pour supprimer les fichiers non suivis. Mettre `requireForce` à `false` permet d'éviter d'avoir à ajouter le flag `-f`.
<br/><br/>

    [diff]
        mnemonicprefix = true

Par défaut lorsque vous faites un 'diff', Git vous affiche par exemple :

    --- a/Git/git.asc
    +++ b/Git/git.asc

Ces préfixes `a/` et `b/` ne sont pas très parlants n'est-ce pas&nbsp;? En passant `diff.mnemonicprefix` à true, Git va afficher des préfixes plus logiques, par exemple `i` pour *index* et `w` pour le *work tree* (votre dossier de travail). Exemple :
    
    --- i/Git/git.asc
    +++ w/Git/git.asc

Pratique.
<br/><br/>

    [help]
        autocorrect = -1

L'une de mes fonctionnalités préférées&nbsp;! Si comme moi vous avez tendance à entrer 'git rzset' comme commande, vous avez déjà vu Git vous dire :

    Did you mean this?
        reset

Mais ne rien faire pour autant&nbsp;! Et bien en activant l'autocorrection, git va remplacer votre commande par `git reset` automatiquement. Il est possible de laisser un délai en donnant un entier positif comme valeur. Ici, avec -1, la correction sera immédiate.
<br/><br/>

    [rerere]
        enabled = true

Si vous avez lu [mon dernier article](http://blog.ninja-squad.com/2013/08/30/git-rerere-ma-commande-preferee/) sur Git, vous savez déjà tout le bien que peut vous apporter 'rerere'&nbsp;!
<br/><br/>

    [push]
        default = upstream

Actuellement (Git < 2.0), Git pousse toutes les branches modifiées qui existent sur le repo distant lors d'une commande `git push` (valeur 'matching'). Je trouve toujours ça un peu dangereux, car on a parfois oublié que l'on a des modifications sur une autre branche que celle en cours, et que l'on ne voudrait pas forcément partager immédiatement. A partir de Git 2.0, la nouvelle valeur sera 'simple' : seule la branche courante sera poussée si une branche du même nom existe. La valeur que je préfère est 'upstream', qui comme 'simple', permet de pousser seulement la branche locale, mais même si la branche distante ne possède pas le même nom.
<br/><br/>

    [rebase]
        autosquash = true
        autostash = true

Lorsque l'on effectue un rebase, Git propose la liste des commits concernés avec un verbe d'action pour chacun (en l'occurence 'pick'). Ce verbe d'action peut être modifié pour devenir 'reword', 'edit', 'squash' ou 'fixup'. Les deux derniers compressent deux commits en un seul. Parfois je sais dès que je commite qu'il devra fusionner avec le précédent. En préfixant le message de commit par 'fixup!', lors du rebase qui viendra, le commit sera automatiquement précédé par le verbe 'fixup' plutôt que 'pick'&nbsp;!

L'option `rebase.autostash` est toute récente (release 1.8.4.2 de Git) et permet d'automatiser une opération un peu pénible. Lorsqu'on lance un rebase, le répertoire de travail doit être sans modification en cours, sinon le rebase ne se lance pas. Il faut alors commiter ou stasher les modifications avant de recommencer le rebase. Avec cette option `rebase.autostash`, le rebase mettra automatiquement les modifications courantes dans le stash avant de faire le rebase, puis ré-appliquera les modifications ensuite.

    [pull]
        rebase = true

Par défaut, 'pull' effectue un 'fetch' suivi d'un 'merge'. Avec l'option 'rebase', 'pull' effectuera un 'fetch' suivi d'un 'rebase'.
<br/><br/>

Allez, pour votre culture, un petit tour des sections moins utiles mais parfois intéressantes.

    [advice]

Il est possible de désactiver tous les conseils que vous affiche Git en cas de problème. C’est un peu comme activer le mode difficile de Git, c’est vous qui voyez...

    [commit]

Il est possible de customiser le template de message de commit avec l'option `commmit.template`. Ça peut être pratique si vous avez des conventions partagées par toute l'équipe (comme [celles de l'équipe AngularJS](http://docs.angularjs.org/misc/contribute)).

Vous pouvez trouver mon '.gitconfig' complet sur mon [repo Github](https://github.com/cexbrayat/dotfiles/blob/master/git/.gitconfig).

Et vous, quelles sont vos options préféréesnbsp;?

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/09/30/git-config-les-options-indispensables "Article original sur le blog de Cédric Exbrayat")_

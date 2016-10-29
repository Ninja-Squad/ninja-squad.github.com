---
layout: post
title: Git rerere - ma commande préférée
author: [cexbrayat]
tags: [git]
canonical: http://hypedrivendev.wordpress.com/2013/08/30/git-rerere-ma-commande-preferee/
---


J’adore faire des rebases. Vraiment. C’est d’ailleurs une part très importante du [workflow que nous vous conseillons](/2013/06/03/branching-with-git/). L’une des choses qui énerve parfois ceux qui font des rebases vient de la résolution de conflit répétitives qui peut survenir. 

Pour rappel, un rebase va prendre tous les commits sur votre branche courante et les rejouer un à un sur une autre. Si vous avez une branche ‘topic1’ avec 5 commits et que vous effectuez un rebase sur la branche ‘master’ alors Git rejoue les 5 commits les uns après les autres sur la branche master.

Parfois, ces commits ont un conflit et le rebase s’arrête, le temps de vous laisser corriger. Mais il arrive que dès que Git passe au commit suivant, vous ayez à nouveau le conflit! Ce qui est très frustrant et pousse parfois à l’abandon du rebase.

Cette situation arrive aussi lorsque l’on doit merger une modification en série sur des branches plus récentes. Par exemple, un bugfix sur la version 1.1, qui doit être mergé sur les branches 1.2 et 2.0. Si un conflit de merge apparaît lors du merge sur 1.2, il est frustrant de l’avoir à nouveau sur la branche 2.0 une fois celui-ci résolu.

Mais, vous vous en doutez, je vous parle de tout ça car Git propose une option à activer une seule fois pour être débarrassé de ces soucis.

Cette commande a le nom le plus improbable de toutes les commandes. rerere signifie reuse recorded resolution : cette commande permet à Git de se rappeler de quelle façon un conflit a été résolu et le résoudre automatiquement de la même façon la prochaine que ce conflit se présente.

Pour activer rerere, la seule chose à faire est de l’indiquer en configuration :

    $ git config --global rerere.enabled true

Une fois activé, Git va se souvenir de la façon dont vous résolvez les conflits, sans votre intervention. Par exemple, avec un fichier nommé bonjour contenant sur master :

    hello ninjas

Une branche french est créée pour la version française :

    bonjour ninjas

Alors que sur master, une modification est appliquée :

    hello ninjas!

Si la branche french est mergée, alors un conflit survient :

    Auto-merging bonjour  
    CONFLICT (content): Merge conflict in bonjour  
    Recorded preimage for 'bonjour'  
    Automatic merge failed; fix conflicts and then commit the result.  

Si l’on édite le fichier, on a bien un conflit :

    <<<<<<< HEAD  
    hello ninjas!  
    =======  
    bonjour ninjas  
    >>>>>>> french  

Vous pouvez voir les fichiers en conflit surveillés par rerere :

    $ git rerere status  
    bonjour  

Vous corrigez le conflit, pour conserver :

    bonjour ninjas!

Vous pouvez voir ce que rerere retient de votre résolution avec :

    $ git rerere diff  
    --- a/bonjour  
    +++ b/bonjour  
    @@ -1,5 +1 @@  
    -<<<<<<<  
    -bonjour ninjas  
    -=======  
    -hello ninjas!  
    ->>>>>>>  
    +bonjour ninjas!  

Une fois terminée la résolution du conflit (add et commit), vous pouvez voir la présence d’un nouveau répertoire dans le dossier .git, nommé rr-cache, qui contient maintenant un dossier correspondant à notre résolution dans lequel un fichier conserve le conflit (preimage) et la résolution (postimage).
Maintenant, vous vous rendez compte que vous vous préféreriez un rebase plutôt qu’un merge. Pas de problème, on reset le dernier merge :

    $ git reset --hard HEAD~1

On se place sur la branche french et on rebase.

    $ git checkout french  
    $ git rebase master
    ...  
    Falling back to patching base and 3-way merge...  
    Auto-merging bonjour  
    CONFLICT (content): Merge conflict in bonjour  
    Resolved 'bonjour' using previous resolution.  
    Failed to merge in the changes.  
    Patch failed at 0001 bonjour ninjas!  

Nous avons le même conflit que précédemment, mais cette fois on peut voir "Resolved bonjour using previous resolution.". Et si nous ouvrons le fichier bonjour, le conflit a été résolu automatiquement!
Par défaut, rerere n’ajoute pas le fichier à l’index, vous laissant le soin de vérifier la résolution et de continuer le rebase. Il est possible avec l’option ‘rerere.autoupdate’ de faire cet ajout automatiquement à l’index (je préfère personnellement laisser cette option à ‘false’ et vérifier moi-même)!
A noter qu’il serait possible de remettre le fichier avec son conflit (si la résolution automatique ne vous convenait pas) :

    $ git checkout --conflict=merge bonjour

Le fichier est alors à nouveau en conflit :

    <<<<<<< HEAD   
    hello ninjas!   
    =======   
    bonjour ninjas   
    >>>>>>> french   

Vous pouvez re-résoudre automatiquement le conflit avec :

    $ git rerere

Magique!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/08/30/git-rerere-ma-commande-preferee/ "Article original sur le blog de Cédric Exbrayat")_

---
layout: post
title: Hibernate 4 et le cache de second niveau
author: acrepet
tags: ["hibernate","cache"]
---
Sur le blog de Ninja Squad, on vous parle souvent de nouveaux trucs sexy comme AngularJS. 
Mais en entreprise, on ne jette pas à la poubelle ses applications toutes les semaines, aussi faut-il souvent maintenir le code legacy. 
Récemment j’ai dû migrer des applications d’Hibernate 3 à Hibernate 4. 
Ayant eu quelques surprises sur la configuration d’Ehcache dans le cadre de cette migration, je me suis dit que ça valait le coup de partager ça avec vous, histoire que cela puisse éventuellement servir à d’autres!

Hibernate peut utiliser plusieurs implémentations pour le cache de second niveau.
Nous avions, pour ces applications, choisi Ehcache.
Il est basé sur un stockage clé-valeur, mais il aurait été possible d’utiliser d’autres fournisseurs de cache plus hypes comme notamment des grilles de données mémoire (In Memory Data Grid) comme [Infinispan](http://infinispan.org/), [Pivotal Gemfire](https://www.pivotal.io/big-data/pivotal-gemfire) ou encore [Hazelcast](http://hazelcast.com/).
Mais non, à l’époque du développment de ces applications, nous avions opté pour le cache par défaut : un bon vieux Ehcache!

# Attention aux dépendances

La première étape pour reconfigurer Ehcache lors de la migration d’Hibernate 3 à Hibernate 4 est la gestion des dépendances.
Il faut tout d’abord embarquer une nouvelle librairie `hibernate-ehcache` depuis Hibernate 4 pour utiliser Ehcache.
Il sera alors nécessaire d’utiliser les packages du type `org.hibernate.cache.ehcache.*` plutôt que `net.sf.ehcache.hibernate.*` dans l’application. 
Par exemple pour déclarer la factory des caches régions, il faut utiliser `org.hibernate.cache.ehcache.SingletonEhCacheRegionFactory` au lieu de`net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory`.
Petit point de vigilance : il faut exclure la dépendance transitive d’`hibernate-ehcache` à `ehcache-core`, puisqu’elle embarque une vieille version de ehcache.
OMG, on utilisait Maven sur ces projets:

        <dependency>
            <groupId>org.hibernate</groupId>
            <artifactId>hibernate-ehcache</artifactId>
            <version>4.3.6.Final</version>
            <exclusions>
                <exclusion>
                    <groupId>net.sf.ehcache</groupId>
                    <artifactId>ehcache-core</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
			
Pour inclure la dépendance à Ehcache la plus récente à ce jour compatible avec Hibernate 4:

		<dependency>
		   <groupId>net.sf.ehcache</groupId>
		   <artifactId>ehcache-core</artifactId>
		   <version>2.6.9</version>
		</dependency>
		
_A noter qu’à partir de la 2.7 d’Ehcache l’artifactID est `ehcache` et non `ehcache-core`_

Il s’agit d’une version 2.6.9 alors qu’à ce jour la version la plus récente d’Ehcache est la 2.8.1!
Et oui, place à une mauvaise surprise : vous ne pouvez pas utiliser la version d’Ehcache que vous voulez avec Hibernate 4.
Seules les versions 2.4.x à 2.6.x peuvent être utilisées (voir les commentaires de [HHH-8732](https://hibernate.atlassian.net/browse/HHH-8732)).
En effet, les dernières versions d’Ehcache, celles à partir de la 2.7, utilisent un nouveau framework pour les statistiques qui demande une évolution côté Hibernate.
Merci d’ailleurs à [Alex Snaps](https://twitter.com/alexsnaps) d’avoir soumis une [pull request](https://github.com/hibernate/hibernate-orm/pull/643) sur le code Hibernate pour remédier à ce problème.
Par contre mauvaise nouvelle : beaucoup espérait que cette pull request soit acceptée sur une version 4.3 d’Hibernate, et bien ce ne sera pas le cas, il va falloir attendre la version 5.0 d’Hibernate qui ne sortira pas avant 2015 à mon avis!
J’avoue avoir été pas mal frustrée par ce point…
Quand vous êtes sur un objectif d’intégration des dernières versions de frameworks techniques dans une application, c’est toujours un peu frustrant de ne pas pouvoir choisir une release récente pour une brique aussi cruciale que celle du cache!

# JCache

Je me suis un peu replongée pour l’occasion dans la [JSR 107](https://jcp.org/en/jsr/detail?id=107) (JCache).
Elle n’a hélas pas été intégrée dans Java EE 7 mais Oracle a annoncé en mars dernier que la spécification devenait finale.
Ce n’est pas trop tôt puisque c’est une des plus vieilles JSR, les premiers travaux ont démarré en 2001!
Ehcache propose un projet [ehcache-jcache](https://github.com/ehcache/ehcache-jcache) qui est une implémentation complète de la JSR 107 (JCache) : il fournit un wrapper sur Ehcache qui vous permet de l’utiliser comme un fournisseur de cache en utilisant uniquement les APIs de JCache.
Mais ce n’est pas le cas d’Hibernate : sa _Caching SPI_ n’utilise pas les APIs de JCache! Dommage!
Le sujet a été abordé [récemment sur la mailing list dev Hibernate](http://lists.jboss.org/pipermail/hibernate-dev/2014-March/011113.html), toujours par [Alex Snaps](https://twitter.com/alexsnaps) qui proposait justement de travailler sur une implémentation de cache basée sur JCache et qui pourrait être incorporée dans Hibernate.
Il imaginait un module hibernate-jcache, comme il y a déjà un module hibernate-cache ou hibernate-infinispan, pouvant proposer des points d’extensions à chaque implémentation spécifique.
Avis aux amateurs si le sujet vous intéresse!

# JavaConfig et exposition des stats

Pour finir un peu de Java Config pour l’exposition des statistiques.
Puisque je migrais les applications, autant essayer de supprimer un maximum de fichiers XML et préférer une configuration programmatique pour toutes les propriétés qui ne sont pas à externaliser pour la production.
Mon objectif était d’exposer en JMX à la fois les statistiques Hibernate et les statistiques Ehcache, le tout donc en Java Config.
La mauvaise surprise est qu’en migrant simplement la configuration XML en Java, l’exposition des stats Hibernate ne marchait plus!
Après un peu de recherche dans les changelogs Hibernate, je me suis aperçue qu’à partir de la version 4.3.0 l’API d’exposition des statistiques avait bien changé.
Dès la version 4.0 le MBean `StatisticsService` est notamment déprécié et carrément supprimé en 4.3.0!
Certains problèmes sont ainsi apparus en version 4.3 : voir en particulier celui-ci [HHH-6190](https://hibernate.atlassian.net/browse/HHH-6190) non résolu!
Et attention [la doc](http://docs.jboss.org/hibernate/orm/4.3/manual/en-US/html_single/#performance-monitoring-sf) sur ce point n’est pas à jour et fait toujours référence au MBean supprimé! 
Voici le code du MBean Hibernate qui fonctionne et expose correctement les stats.
Vous remarquerez un bout de code bizarre `Proxy.newProxyInstance(..)` pour récupérer une instance du MBean, workaround à l’anomalie précédente s’appuyant sur un proxy dynamique, `Statistics` étant l’interface exposant les statistiques pour une SessionFactory.

    @Configuration
    public class JmxConfig {

    @Bean
    public Object hibernateStatisticsMBean(@Qualifier("sessionFactory") SessionFactory sessionFactory) {

        final Statistics statistics = sessionFactory.getStatistics();
        statistics.setStatisticsEnabled(true);
        Object hibernateStatisticsMBean = Proxy.newProxyInstance(getClass().getClassLoader(), new Class<?>[]{Statistics.class}, new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                return method.invoke(statistics, args);
            }
        });
        return hibernateStatisticsMBean;
        }
        ...
    }

Vous pouvez ensuite tout simplement déclarer votre MBeanServer existant en lui injectant les beans à exposer.
Remarquez aussi en une seule ligne de code l’exposition du cache Ehcache:

    @Bean
    public MBeanServer mbeanServer() {
        return ManagementFactory.getPlatformMBeanServer();
    }

    @Bean
    public MBeanExporter mbeanExporter(Object hibernateStatisticsMBean, MBeanServer mBeanServer, InterfaceBasedMBeanInfoAssembler mbeanInfoAssembler) {
        MBeanExporter mBeanExporter = new MBeanExporter();
        mBeanExporter.setServer(mBeanServer);
        mBeanExporter.setAutodetect(false);
        mBeanExporter.setRegistrationPolicy(RegistrationPolicy.REPLACE_EXISTING);
        Map myMap = new HashMap<String, Object>();
        
        // exposer vos autres éléments JMX : myMap.put(...);
        myMap.put("com.ninja_squad.jmx:name=HibernateStatistics", hibernateStatisticsMBean);
        mBeanExporter.setBeans(myMap);

        // mbeanInfoAssembler permet de spécifier les méthodes et les propriétés exposées
        mBeanExporter.setAssembler(mbeanInfoAssembler);
        
        // Exposition Ehcache
        ManagementService.registerMBeans(CacheManager.newInstance(), mBeanServer, false, false, false, true);
        
        return mBeanExporter;

    }

Et voilà pour mes péripéties avec Hibernate 4! En espérant permettre à certains d’épargner quelques heures d’égarement dans les changelogs et les JIRA d’Hibernate ;-)


---
layout: post
title: The story of a Java to Kotlin migration
author: jbnizet
tags: ["Kolin", "Java", "Grade"]
description: "We migrated a project to Kotlin, and its build to the Gradle Kotlin DSL"
---

<div style="float: right;"><img src="/assets/images/2016-05-31/kotlin.png" alt="Kotlin logo" /></div>

Cyril and Agnès already told you about [our side project](/2017/12/08/ninja-squad-caritatif/) for [Globe 42](/2018/05/10/globe42/), a local association which helps old migrants in Saint-Etienne. 
We started this project as a traditional Spring Boot Java backend, with an Angular frontend.
The backend uses Spring MVC to expose RESTful endpoints, and uses JPA to access a PostgreSQL database.
The whole application is built with Gradle.

We finally decided to migrate it to Kotlin: it's a nice medium-sized project to learn more about it, and, having already [played with Kotlin](/2016/05/31/first-kotlin-project/) and liking it a lot, there was no reason not to do it.

We also decided to migrate the gradle scripts to the Kotlin DSL. If that's what you're interested about, you can jump to the last section of this article.

Here's how it went. If you're interested into the end result, [the code is on GitHub](https://github.com/Ninja-Squad/globe42).

## Strategy

I did everything by myself, in a single pass: everything (except the gradle build) was migrated at once, in a single (but long) day. 
Small refinements and adjustments were brought in later, but the whole code was migrated at once. 

Beware though. 
Globe42 is a relatively small project (around 10,000 lines of Java code, not counting comments and blank lines, but including tests). 
For a larger project, it would probably be wiser to split such a migration in smaller pieces. 
But anyway, the strategy I adopted can probably be used.

This migration was also made easy by the facts that I already had this idea of migrating it to Kotlin when the project was started, and the code was written with most of the best practices making it easy to migrate and making the code Kotlin-friendly: constructor injection, immutable DTOs, etc.

I began without a real plan, taking the first package arbitrarily, and migrating it. 
This wasn't a good idea: the package depended on other downstream packages (still written in Java). 
This means that the migrated code still used a lot of [platform types](https://kotlinlang.org/docs/reference/java-interop.html#null-safety-and-platform-types), although I knew that these platform types would disappear later during the migration. 
I would thus have to come back to the migrated code later, once its downstream dependencies would have been migrated. It thus became clear that the good strategy was to start with the lowest layers of the code (entities, DTOs), then go up through the layers (DAOs, then services and controllers, and finally tests).

The migration was in fact largely automated by IntelliJ, which has a nice *Convert Java file to Kotlin* action. 
Note that, despite its name, this action can actually be executed on several files, or a whole directory at once.

## Migration issues

The converter does a pretty good job, but isn't perfect, and can't read in your mind. Here are some of the things I had to change manually.

### Constants

I have a static final field used as a value of an annotation attribute:

```
    private static final String PERSON_GENERATOR = "PersonGenerator";
    
    @SequenceGenerator(name = PERSON_GENERATOR, sequenceName = "PERSON_SEQ")
```

The converter transforms the constant to a field of the companion object of the class:

```
    companion object {
        private val PARTICIPATION_GENERATOR = "ParticipationGenerator"
    }

    @SequenceGenerator(
        name = PARTICIPATION_GENERATOR,
        sequenceName = "PARTICIPATION_SEQ"
    )
```

But only `const val` can be used as a value of an annotation attribute. So that code doesn't compile.

### Field injections

I actually had one field injection:

```
    @PersistenceContext
    private EntityManager em;
```

The converter converts it to 

```
    @PersistenceContext
    private val em: EntityManager? = null
```

This is technically correct. But not semantically correct. The code will never see `em` as null. It's just that it will be initialized right after construction by Spring. So the semantically correct code is

```
    @PersistenceContext
    private lateinit var em: EntityManager
```

Another place where we have lots of field injections is in tests (using the `@Mock` and `@InjectMocks` annotations of Mockito, and the `@MockBean` annotation of Spring). Once again, all those has to manually be changed to `lateinit var` instead of nullable properties.

### Not null fields of JPA entities

JPA entities work basically the same way as field-injected Spring beans. 
When reading an entity from the database, JPA constructs it by using the no-arg constructor, and then populates its fields. 
This means that, although a person always has a gender in the database, the `gender` field of the entity is initially null, and then populated by JPA.

So, the following code

```
    @NotNull
    var gender: Gender? = null
```

is converted to

```
    @NotNull
    var gender: Gender? = null
```

Once again, this is technically correct, but not semantically correct. 
The gender is not supposed to be null. 
It's just always supposed to be initialized after construction. 

Note that even in the case of the *creation* of a new person (where our own code invokes the constructor and populates the entity), the gender is supposed to be set, either directly in the constructor, or right after construction, before it's ever read. 

So we decided to change this code to

```
    @NotNull
    lateinit var gender: Gender
```

It should now be clearer why starting with the downstream layers of the code is a better idea. Having a `Gender` rather than a `Gender?` here allows upstream layers to rely on this non-null type, and thus makes the code simpler, more idiomatic, and easier to convert (since the Java code already made that assumption that the gender could never be null).

### Entity IDs 

We use `Long` for most of our entity IDs. 
And they are all auto-generated by JPA. Once again, this means that technically, the ID is nullable, but that semantically, the ID should never be read as null: either the entity is read by JPA and the ID is not null, or the entity is created, and we should make sure that the ID is generated (by flushing the EntityManager if necessary) before we read it.

Unfortunately, Kotlin doesn't support `lateinit var` for Long.

The code 

```
    lateinit var id: Long
```

doesn't compile: `'lateinit' modifier is not allowed on properties of primitive types`.

This is surprising to me. Maybe I'm missing something, but Kotlin could deal with this for me by using a `java.lang.Long` instead of a `long`, just as it does transparently when using a property of type `Long?` rather than `Long`. 

But we can't do much about that, and we preferred not using a primitive type as the ID (Hibernate recommends using nullable, non-primitive types for generated IDs). 
So we kept using `var id: Long?` for our IDs, even though it forces us to use the `!!` operator (in tests mainly). 
Maybe we'll change this strategy later. 
If you have an explanation on why Kotlin doesn't allow `lateinit var` on Long, I'd be happy to learn about it.

### DTOs

Our DTOs (sent as JSON from the server, or received as JSON from the browser) were really meant, from the beginning, to be immutable data classes. 
Except data classes don't exist (yet) in Java. 
And IntelliJ can't read in your mind. 
So we converted all our DTOs to data classes by hand.

Note that we didn't use data classes for the JPA entities.
This is an anti-pattern to me, for the following reasons:

 - in general, I prefer not to have `hashCode()` and `equals()` methods in entities. And data classes do have such methods. `equals()` and `hashCode()` on entities are most of the time semantically incorrect because entities are mutable, and are stored in HashSets, which break the HashSet contract.
 - It's sometimes possible, but hard, to write `equals()` and `hashCode()` methods correctly for entities, but they should not use their auto-generated ID. And data classes include all the fields of the class in those methods. 


### Stream operations

This is where the converter really does a bad job at converting code. This simple, idiomatic Java line of code:

```
    public List<CountryDTO> list() {
        return countryDao.findAllSortedByName()
                         .stream()
                         .map(CountryDTO::new)
                         .collect(Collectors.toList());
    }
```

is converted to this non-compiling Kotlin monstruosity:

```
    fun list(): List<CountryDTO> {
        return countryDao.findAllSortedByName().stream()
            .map<CountryDTO>(Function<Country, CountryDTO> { CountryDTO(it) })
            .collect<List<CountryDTO>, Any>(Collectors.toList())
    }
```

So we changed all these kinds of code to the following idiomatic Kotlin code:

```
    fun list(): List<CountryDTO> {
        return countryDao.findAllSortedByName().map(::CountryDTO)
    }
```

### Tests

We use Mockito a lot in our tests. 
And using Mockito with Kotlin is only really possible with the [mockito-kotlin](https://github.com/nhaarman/mockito-kotlin) library. 
So we had to manually change all the calls to `when`, `verify`, `any`, etc. by calls to the mockito-kotlin extension functions (`whenever`, etc.) 

The idiomatic way of naming a test method in Kotlin is to use a real sentence. So we wrote and executed a simple script to change all the methods like

```
    fun shouldNotUpdateMediationCodeIfLetterStaysTheSame()
```

to 

```
   fun `should not update mediation code if letter stays the same`()
```

### Meta annotations

This is the only thing that we could not migrate to Kotlin. We have the following meta-annotation:

```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@ExtendWith(SpringExtension.class)
@WebMvcTest(
    excludeFilters = @ComponentScan.Filter(
        type = FilterType.ASSIGNABLE_TYPE,
        classes = {AuthenticationConfig.class}))
public @interface GlobeMvcTest {
    @AliasFor(annotation = WebMvcTest.class, attribute = "value")
    Class<?>[] value() default {};
}
```

I tried everything I could to convert this annotation to Kotlin, until I realized that it was actually not possible due to [this known bug](https://youtrack.jetbrains.com/issue/KT-11475): it's impossible to apply an annotation to an annotation method in Kotlin. So this is the only Java class remaining in our code.

## Takeaways

The takeaway is the following: it's possible to convert to Kotlin, and the automatic converter helps a lot, but you should start with the downstream, lower layers of the code, and you **will** have to apply manual adjustments to the converted code, either to fix it, or to make it cleaner and more idiomatic.

In the end, I'm very happy with the result. The code is easier to read. We didn't actually find bugs thanks to the migration, but the code is now cleaner, and reduced from approximately 10,000 lines of code to 8,000 (mainly due to getters and setters being removed).

We found two small negative side effects though:

 - the code coverage, measured by Jacoco, went down significantly. The reason is that data classes contain a lot of generated code (equals, hashCode, copy, component1, component2, etc.) that are never actually used in the code. Not a big deal, but if you have a way to configure jacoco to ignore those methods, I'd be happy to learn about it.
 - the compilation time (which is a ridiculous time compared to the time needed to run the tests, and even more ridiculous compared to the time needed to build the frontend) went from 3 seconds in Java to 10 seconds in Kotlin. This shows how remarkably fast the Java compiler is, and how the Kotlin compiler can probably improve.

## Migrating the Gradle build

Migrating the groovy-based gradle scripts to Kotlin was the next natural step. 
This is much faster to do, because there is much less code to migrate. 
The difficulty is the lack of documentation. 
So [I wrote a migration guide](https://github.com/jnizet/gradle-kotlin-dsl-migration-guide/blob/master/README.adoc). 


Gradle's reaction was excellent. Since I wrote it, [eskatos](https://github.com/eskatos), from the Gradle team, kindly improved it, and contacted me to tell me that it would soon become the basis for an official gradle guide, and to ask for contribution to the Kotlin DSL documentation.

So the Gradle documentation should soon include Kotlin examples and guides in addition to Groovy ones \o/.

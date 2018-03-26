---
title: "Android: Robolectric Unit Testing a Local Disk-Based SQLite Database"
description: false
date: 2013-11-22 22:39:52
category: blog
comments_enabled: true
layout: blog-post
tags: [android, mobile, development, robolectric, sqlite, testing]
---

Documentation was sparse regarding how to run Robolectric unit tests on a local
database file stored on your computer. So here is what I managed to find.

### The Problem

Robolectric is a great framework for running Android unit tests without having
to deploy the application to your device or to an emulator. As a result, this
significantly speeds up unit testing during Android application development.

However, SQLite databases become tricky when you have a premade database on
which you wish to operate and invoke tests. This is because Roboletric uses an
"in-memory" database for all SQLite operations. This works great, if you are
running database creation queries and building your tables directly within the
testing environment. Otherwise, you may find yourself looking for a way to test
on a premade database.

Don't worry. If you want to use a pre-made database and run your tests on that
SQLite file, Robolectric's got your back.

### The Solution

First, ensure that the Robolectric dependency in your `pom.xml` file is version
2.1 or later. Support for local disk-based SQLite testing was [introduced in
version 2.1](http://robolectric.blogspot.com/2013/05/robolectric-21.html).

```xml|linenos
<dependency>
  <groupId>org.robolectric</groupId>
  <artifactId>robolectric</artifactId>
  <version>2.2</version>
  <scope>test</scope>
</dependency>
```

Once you have that done, place a copy of your database file in the
`${project_root}/src/test/resources` directory.

When you compile your tests, files in this directory will get copied into an
"output directory" containing all the compiled classes and files. On my machine,
the directory is located at `${project_root}/target/test-classes`. Thus, the
file you place in the `${project_root}/src/test/resources` directory will not be
modified in any way. The copied file in the "output directory" *will* be
modified. Any database operations performed in your unit tests will be operating
on that "output directory" database file.

Now create a new Java test file. We'll call ours `DaoTest.java`:

```java|linenos
@RunWith(RobolectricTestRunner.class)
public class DaoTest {

  // This path is relative to ${project_root}/src/test/resources
  // This path is used in building the absolute path for the database
  private static final string DB_PATH = "/database/MyDbFile.db";
  // This will contain the absolute file path to the database
  private string dbPath;

  @Before
  public void setUp() throws Exception {
    String path = getClass.getResource(DB_PATH).toURI().getPath();
    File dbFile = new File(path);
    assertThat(dbFile.exists()).isTrue();
    dbPath = dbFile.getAbsolutePath();

    // Perform any other necessary set-up operations...
  }

  @After
  public void tearDown() throws Exception {
    // Perform any necessary clean-up operations...
  }

  @Test
  public void testGet() throws Excpetion {
    SQLiteDatabase db = SQLitedatabase.open(dbPath, null, OPEN_READWRITE);

    // Perform database operations...

    // Perform assertions on query results...

    db.close();
  }
}
```

That's it. It really is that simple!

`dbPath` will contain the absolute path to the database file in that "output
directory." From there, you can invoke `SQLiteDatabase.openDatabase()` and
perform any necessary operations on the disk-based SQLite database file.


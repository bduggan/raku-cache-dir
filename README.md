NAME
====

Cache::Dir - A simple key-value store using the filesystem.

SYNOPSIS
========

    use Cache::Dir;
    my $cache = Cache::Dir.new: dir => $*HOME.child('.cache');

    $cache.get-cached: 'answer', 42;
    $catch.get-cached: 'question', { "why?" };
    $cache.exists: 'answer';          # true
    $cache.get: 'answer';             # 42
    $cache.remove: 'answer';
    $cache.get('question');           # why?

DESCRIPTION
===========

This module provides simple key-value storage using the filesytem.

Each key is stored in a separate file. The filename is a SHA1 of the key. If the key not a string or numeric, then it is serialized using `.raku` before taking the sha.

Serialization of the value is done using `.raku` and deserialization is done using `.EVAL`.

Storage is done with atomic write-and-rename, so depends on a filesystem that has those semantics. The age of the key is also filesytem dependent.

Note that the key is not stored, so there's no way to get a list of keys. However it is possible to get a list of "entries", which are objects that include their age, storage path, and value (see [Cache::Dir::Entry](Cache::Dir::Entry) below).

METHODS
=======

method get-cached
-----------------

    method get-cached($key, $val) returns Mu
    method get-cached($key, &v) returns Mu

Return a value if it has been stored, or store the provided value. If the value is a routine, it is called.

method get
----------

    method get($key) returns Mu
    method get($key, $val) returns Mu
    method get($key, &v) returns Mu

Get a value with a provided default (but don't store).

method store
------------

    method store($key, $value) returns Mu
    method store($key, &v) returns Mu

Store a value for a key. If the value is a routine, the result of calling it is stored.

method remove
-------------

    method remove($key) returns Mu

Remove a key from the cache.

method exists
-------------

    method exists($key) returns Bool

Check if a key exists in the cache.

method age-seconds
------------------

    method age-seconds($key) returns Int

Return the number of seconds since the key was last modified.

method flush
------------

    method flush returns Mu

Remove all entries from the cache.

method get-entries
------------------

    method get-entries returns Array

Return a list of Cache::Dir::Entry objects, which can be used to inspect and remove individual entries.

Cache::Dir::Entry
=================

method clear
------------

    method clear returns Mu

Remove the entry from the cache.

method value
------------

    method value returns Mu

Return the value of the entry.

method age-seconds
------------------

    method age-seconds returns Int

Return the number of seconds since the entry was last modified.

method modified
---------------

    method modified returns DateTime

Return the last modified time of the entry.

AUTHOR
======

Brian Duggan


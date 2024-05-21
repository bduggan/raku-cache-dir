NAME
====

Cache::Dir - A simple file-based cache

SYNOPSIS
========

    use Cache::Dir;
    my $cache = Cache::Dir.new(dir => 'cache');
    $cache.get-cached('key', 'value'); # Returns 'value' and stores it in the cache

DESCRIPTION
===========

This module provides a simple file-based cache. It stores values in files in a directory, using a sha1 hash of the key as the filename. Values are stored in Raku's serialization format.

The storage relies on the filesystem for atomicity (write-and-rename), and does not store the key anywhere. Without the key, it is possible to retrieve a list of entries (Cache::Dir::Entry), which may be expired individually. The entire cache can also be flushed.

METHODS
=======

method get-cached
-----------------

    method get-cached($key, $val) returns Mu
    method get-cached($key, &v) returns Mu

Return a key if it exists, or store the provided value. The value can be a scalar or a routine.

method get
----------

    method get($key) returns Mu
    method get($key, $val) returns Mu
    method get($key, &v) returns Mu

Get a value with a default scalar or routine

method store
------------

    method store($key, $value) returns Mu
    method store($key, &v) returns Mu

Store a value with a key. The value can be a scalar or a routine.

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

method all-keys
---------------

    method all-keys returns Array

Return a list of all keys in the cache.

method flush
------------

    method flush returns Mu

Remove all keys from the cache.

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


use Digest::SHA1::Native;

class Cache::Dir::Entry {
  has IO::Path $.storage-location is required;
  method clear {
    $.storage-location.unlink;
  }
  method value {
    $.storage-location.slurp.EVAL;
  }
  method age-seconds {
    (DateTime.now - $.storage-location.modified.DateTime).Int;
  }
  method modified {
    $.storage-location.modified;
  }
      
}

class Cache::Dir {
  has IO::Path $.dir is required;

  method TWEAK {
    $.dir.d or mkdir $.dir;
  }

  multi method get-cached($key, $val) {
    self.get($key) andthen .return;
    return self.store($key, $val);
  }
  multi method get-cached($key, &v) {
    self.get($key) andthen .return;
    return self.store($key, v());
  }

  multi method get($key) {
    try return self!storage-path($key).slurp.EVAL;
    Nil;
  }
  multi method get($key, $val) {
    self.get($key) andthen .return;
    $val;
  }
  multi method get($key, &v) {
    self.get($key) andthen .return;
    v;
  }

  method !filename($key) {
    sha1-hex($key ~~ (Str|Numeric) ?? $key.Str !! $key.raku);
  }

  method !storage-path($key) {
    $.dir.child(self!filename($key));
  }

  multi method store($key, $value) {
    my $filename = self!filename($key);
    my $tmp = $.dir.child($filename ~ "-$*PID-" ~ $*THREAD.id ~ '-' ~ now.Rat ~ 1.rand ~ ".tmp");
    $tmp.spurt: $value.raku;
    $tmp.rename($.dir.child($filename));
    $value;
  }
  multi method store($key,&v) {
    self.store($key, v());
  }

  method remove($key) {
    unlink self!storage-path($key);
  }
  method exists($key) {
    self!storage-path($key).e;
  }

  method age-seconds($key) {
    (DateTime.now - self!storage-path($key).modified.DateTime).Int;
  }
  method get-entries {
    $.dir.dir.map: -> $f {
      Cache::Dir::Entry.new(storage-location => $f);
    }
  }
  method flush {
    $.dir.dir».unlink;
  }
}

=begin pod

=head1 NAME

Cache::Dir - A simple key-value store using the filesystem.

=head1 SYNOPSIS

=begin code
use Cache::Dir;
my $cache = Cache::Dir.new: dir => $*HOME.child('.cache');

$cache.get-cached: 'answer', 42;
$catch.get-cached: 'question', { "why?" };
$cache.exists: 'answer';          # true
$cache.get: 'answer';             # 42
$cache.remove: 'answer';
$cache.get('question');           # why?

=end code

=head1 DESCRIPTION

This module provides simple key-value storage using the filesytem.

Each key is stored in a separate file.  The filename is a SHA1 of
the key.  If the key not a string or numeric, then it is serialized
using `.raku` before taking the sha.

Serialization of the value is done using `.raku` and deserialization
is done using `.EVAL`.

Storage is done with atomic write-and-rename, so depends on a filesystem
that has those semantics.  The age of the key is also filesytem dependent.

Note that the key is not stored, so there's no way to get a list of keys.
However it is possible to get a list of "entries", which are objects that
include their age, storage path, and value (see L<Cache::Dir::Entry> below).

=head1 METHODS

=head2 method get-cached
  =begin code
  method get-cached($key, $val) returns Mu
  method get-cached($key, &v) returns Mu
  =end code

Return a value if it has been stored, or store the provided value.  If the value is a routine, it is called.

=head2 method get
  =begin code
  method get($key) returns Mu
  method get($key, $val) returns Mu
  method get($key, &v) returns Mu
  =end code

Get a value with a provided default (but don't store).

=head2 method store
  =begin code
  method store($key, $value) returns Mu
  method store($key, &v) returns Mu
  =end code

Store a value for a key.  If the value is a routine, the result of
calling it is stored.

=head2 method remove
  =begin code
  method remove($key) returns Mu
  =end code

Remove a key from the cache.

=head2 method exists
  =begin code
  method exists($key) returns Bool
  =end code

Check if a key exists in the cache.

=head2 method age-seconds
  =begin code
  method age-seconds($key) returns Int
  =end code

Return the number of seconds since the key was last modified.

=head2 method flush
  =begin code
  method flush returns Mu
  =end code

Remove all entries from the cache.

=head2 method get-entries
  =begin code
  method get-entries returns Array
  =end code

Return a list of Cache::Dir::Entry objects, which can be used to inspect and remove individual entries.

=head1 Cache::Dir::Entry

=head2 method clear
  =begin code
  method clear returns Mu
  =end code

Remove the entry from the cache.

=head2 method value
  =begin code
  method value returns Mu
  =end code

Return the value of the entry.

=head2 method age-seconds
  =begin code
  method age-seconds returns Int
  =end code

Return the number of seconds since the entry was last modified.

=head2 method modified
  =begin code
  method modified returns DateTime
  =end code

Return the last modified time of the entry.

=head1 AUTHOR

Brian Duggan

=end pod

# vim: expandtab shiftwidth=2 ft=perl6

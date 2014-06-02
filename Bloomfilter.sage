import mmh3
import collections

class Bloomfilter(object):
    """
    A bloom filter is a probabilistic data structure used for membership testing.  Objects added to a bloom filter are not actually stored in the filter; rather, each added object is hashed several times, and the corresponding bits are set in a bit vector.  When an object is tested for membership, it is hashed by the same hash functions, and the resulting bits are checked in the bit vector.  If all corresponding bits are set, it is said that the element "may" have been added to the filter; if at least one of the bits is not set, however, it is definitely the case that the object is not a member of the filter.  Note that, in this way, a bloom filter may return false positives for membership testing, but will never produce false negatives.  That is, a bloom filter should be used when it is desirable to know with some degree of certainty that an object "might" be a member, and with absolute certainty that an object is not a member.

    Note that, due to the use of a bit vector to represent the underlying data, it is not possible to retrieve the members added to a filter (nor to iterate, remove, etc.).  If retrievability is desired, or if false positives are not tolerated, a user would be better suited using the builtin set type in python.  However, these concessions allow for extremely space efficient storage (linear in the size of the bit vector), as well as fast lookup (linear in the number of hash functions used - regardless of the number of added members).  Bloomfilters are often effectively used as a pre-screening measure, with a traditional set containing all members stored on disk.

    Further, note that due to the bit vector representation, intersection, difference, symmetric difference are all meaningless in the context of a bloom filter.  As such, only insertion and union operations are the only possible set behaviors, in addition to membership testing.
    """
    def __init__(self, iterable=None, size=128, max_fp_rate=0.25, hash_count=4):
        """
        Initializes a bloom filter, either as an empty bit vector of the given size, or containing the elements in the given iterable, if one is provided.

        INPUT:
            -iterable -- an iterable collection, from which all elements will be initially added to the filter
            -size -- the size of the underlying bit vector to be used for the filter
            -max_fp_rate -- the maximum allowable rate of estimated false positives
            -hash_count -- the number of hash functions to use
        """
        if (iterable is not None):
            #TODO: make capacity appropriate to iterable's size and max_fp_rate
            #TODO: try-catch initialization of the Bitset; better to throw a more localized exception than Bitset's
            self.bits = Bitset(iterable, capacity=size)
        else:
            self.bits = Bitset(capacity=size)
        self.size = size
        self.max_fp_rate = max_fp_rate
        self.hash_count = hash_count

    def __repr__(self):
        """
        Returns a string representing the given bloom filter.  The following information is included in this string: capacity of the underlying bit set, number of hash functions used, maximum allowed false-positive rate, and the underlying bitset itself.
        
        EXAMPLES::
            sage: Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)            
            Bloomfilter(size=128, hash_count=4, max_fp_rate=0.250000, bits=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
        """
        return "Bloomfilter(size=%i, hash_count=%i, max_fp_rate=%f, bits=%s)" % (self.size, self.hash_count, self.max_fp_rate, repr(self.bits))

    def __eq__(self, other):
        """
        Checks for equality between other and self.  Returns true if and only if other is an instance of bloom filter, with the same allowed false positive rate, and the exact same bit vector state as self; otherwise false.
        
        Note that, due to the nature of how a bloom filter stores its members (i.e. in hashed bits, rather than the members themselves), it is possible that two bloom filters with entirely different member sets could test true for equality.  Though this sense of equality may intuitively seem odd, this is intended behavior; that is, two filters may be used interchangeably a point in which their bitsets are equal, so two such filters are in fact equal.
        
        Further note that, in the testing of this function, the above consideration may be important if tests are failing.  That is, a test may fail simply due to bad luck with hash functions (though this is unlikely), so this possiblity should always be explored before blaming the equality function itself.

        INPUT:
            -other -- a bloom filter, to test equality with self

        OUTPUT:
            a boolean, indicating equality of self and other
            
        EXAMPLES::
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a == b
            True
            
            sage: a = Bloomfilter(size=64, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a == b
            False
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.1, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a == b
            False
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=3)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a == b
            False
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a.add("hello")
            sage: b.add("hello")
            sage: a == b
            True
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a.add("hello")
            sage: b.add("hi")
            sage: a == b
            False
        """
        if isinstance(other, Bloomfilter):
            return ((self.size == other.size) and
                   (self.bits == other.bits) and
                   (self.max_fp_rate == other.max_fp_rate) and
                   (self.hash_count == other.hash_count))
        else:
            return NotImplemented

    def __ne__(self, other):
        """
        Checks for non-equality between other and self.  Returns false if and only if other is an instance of bloom filter, with the same allowed false positive rate, and exact same bit vector state as self; otherwise true.
        
        See documentation for eq method for special notes and considerations.

        INPUT:
            -other -- a bloom filter, to test non-equality with self

        OUTPUT:
            a boolean, indicating non-equliaty of self and other
            
        EXAMPLES::
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a != b
            False
            
            sage: a = Bloomfilter(size=64, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a != b
            True
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.1, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a != b
            True
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=3)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a != b
            True
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a.add("hello")
            sage: b.add("hello")
            sage: a != b
            False
            
            sage: a = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: b = Bloomfilter(size=128, max_fp_rate=0.25, hash_count=4)
            sage: a.add("hello")
            sage: b.add("hi")
            sage: a != b
            True
        """
        if isinstance(other, Bloomfilter):
            return ((self.size != other.size) or
                   (self.bits != other.bits) or
                   (self.max_fp_rate != other.max_fp_rate) or
                   (self.hash_count != other.hash_count))
        else:
            return NotImplemented

    def __contains__(self, n):
        """
        Tests for possible membership of the hashable object n in self.  Note that "true" only means n is probabilistically a member of self, though this may not be the case; a "false", however, indicates with absolute certainty that n is not a member of self.
        
        Membership testing is meant to be carried out in exactly the same fashion as adding (though now hashed buckets are checked for a set bit, rather than performing the setting of the bit).  For any questions regarding the methodology used in membership testing, see documentation of add() for more details.
        
        Further, note that the behavior of the __contains__ function is exactly identical to the mightContain() function.  This is to allow the user to use whatever style of membership testing they prefer in their code.  "x in y" syntax (from __contains__) is preferable for elegance, but "y.mightContain(x)" might provide a more clear indication that membership testing is only probabilistic.

        INPUT:
            -n -- an object, to test for membership in self

        OUTPUT:
            a boolean, indicating if n is possibly a member of self
            
        EXAMPLES::
            sage: a = Bloomfilter(size=16, hash_count=3, max_fp_rate=0.25)
            sage: a.add(5)
            sage: 5 in a
            True
           
            sage: a.add("skateboard")
            sage: "skateboard" in a
            True
            
            sage: 6 in a
            False
            
            sage: set() in a
            False
        """
        if isinstance(n, basestring):
            # have a string - just use murmur hash on string itself
            for i in range(self.hash_count):
                hash_val = mmh3.hash(n,i) % self.size
                if not hash_val in self.bits:
                    return False
            return True 
        elif isinstance(n, collections.Hashable):
            # have a hashable non-string; take first hash, then continually re-hash str(previous hash)
            last_hash = hash(n)
            for i in range(self.hash_count):
                last_hash = mmh3.hash(str(last_hash),i) % self.size
                if not last_hash in self.bits:
                    return False
            return True
        else:
            # have a non-hashable object, cannot possibly be in filter (see add())
            return False
        
    def mightContain(self, n):
        """
        Tests for possible membership of the hashable object n in self.  Note that "true" only means n is probabilistically a member of self, though this may not be the case; a "false", however, indicates with absolute certainty that n is not a member of self.
        
        Further, note that the behavior of the __contains__ function is exactly identical to the mightContain() function.  This is to allow the user to use whatever style of membership testing they prefer in their code.  "x in y" syntax (from __contains__) is preferable for elegance, but "y.mightContain(x)" might provide a more clear indication that membership testing is only probabilistic.

        INPUT:
            -n -- an object, to test for membership in self

        OUTPUT:
            a boolean, indicating if n is possibly a member of self
            
        EXAMPLES::
            sage: a = Bloomfilter(size=16, hash_count=3, max_fp_rate=0.25)
            sage: a.add(5)
            sage: a.mightContain(5)
            True
           
            sage: a.add("skateboard")
            sage: a.mightContain("skateboard")
            True
            
            sage: a.mightContain(6)
            False
            
            sage: a.mightContain(set())
            False
        """
        return n in self

    def add(self, n):
        """
        Inserts hashable object n into self.  Note that n is not retrievable in the future (as only the bits resulting from the hash of n are retained), but, following the insertion, self will always return true when testing n for membership.
        
        Note that the current implementation of the hashing scheme has NOT been tested for a uniform spread for non-string objects.  That is, for strings that are added, the set of murmur hash functions is used to hash the string.  Murmur has been shown to possess good distribution over random strings, and may thus be trusted to do so for added strings in the bloom filter.  However, murmur operates on strings, and no general-purpose hash function was found that both works on any hashable object type, and allows for multiple hash functions (similar to how murmur may be seeded).  The current implementation of Bloomfilter then, uses the set of murmur hash functions to hash and re-hash the result of any hashable object's built-in __hash__ value, put into string form.  This should not necessarily be trusted to give an optimal distribution of hash values, and for specific use cases of bloom filters, it will often be a good idea to create a subclass of Bloomfilter, with a more implemntation-specific hashing scheme for the add() and contains() methods.

        INPUT:
            -n -- a hashable object, to add to self
            
        EXAMPLES::
            sage: a = Bloomfilter(size=16, hash_count=3, max_fp_rate=0.25)
            sage: a.add(5); a
            Bloomfilter(size=16, hash_count=3, max_fp_rate=0.250000, bits=0000100000000100)
            
            sage: a.add(5); a.add(5); a.add(5); a
            Bloomfilter(size=16, hash_count=3, max_fp_rate=0.250000, bits=0000100000000100)
            
            sage: a.add("skateboard"); a
            Bloomfilter(size=16, hash_count=3, max_fp_rate=0.250000, bits=0000100010000101)
        """
        if isinstance(n, basestring):
            # have a string - just hash it each time
            for i in range(self.hash_count):
                hash_val = mmh3.hash(n,i) % self.size # uses the i-th murmur hash function - thereby providing necessary multiple hash functions
                self.bits.add(hash_val)
        elif isinstance(n, collections.Hashable):
            # have a hashable non-string; take first hash, then continually re-hash str(previous hash)
            last_hash = hash(n)
            for i in range(self.hash_count):
                last_hash = mmh3.hash(str(last_hash),i) % self.size
                self.bits.add(last_hash)
        else:
            raise TypeError("unhashable type: '%s'" % n.__class__.__name__)

    def union(self, other):
        """
        Returns a new Bloomfliter representing the union of the underlying bit vectors for self, and another bloom filter, with the same max false positive rate and capacity as self.  This is semantically equivalent to taking the union of the member sets of the two filters, as any element that is a member of one will also be a member of the resulting bloom filter.

        INPUT:
            -other -- a bloom filter, to union with self

        OUTPUT:
            a bloom filter, the union of other and self
            
        EXAMPLES::
            sage: a = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: a.add(5)
            sage: a
            Bloomfilter(size=8, hash_count=2, max_fp_rate=0.250000, bits=00001100)

            sage: b = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: b.add("skateboard")
            sage: b
            Bloomfilter(size=8, hash_count=2, max_fp_rate=0.250000, bits=10000001)
                    
            sage: a.union(b)
            Bloomfilter(size=8, hash_count=2, max_fp_rate=0.250000, bits=10001101)
        """
        if not isinstance(other, Bloomfilter):
            raise TypeError("may not union Bloomfilter with object of type: '%s'" % other.__class__.__name__)
        res = Bloomfilter(size=self.size, max_fp_rate=self.max_fp_rate, hash_count=self.hash_count)
        res.bits = self.bits.union(other.bits)
        return res

    def getVectorSize(self):
        """
        Returns the size of the underlying bit vector.

        OUTPUT:
            an integer, representing the total number of buckets in self's underlying bit vector
            
        EXAMPLES::
            sage: a = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: a.getVectorSize()
            8
            
            sage: b = Bloomfilter(size=1024, hash_count=2, max_fp_rate=0.25)
            sage: b.getVectorSize()
            1024
        """
        return self.size

    def getLoadFactor(self):
        """
        Returns the load factor of the underlying bit vector.  This is the number of set bits in the vector, divided by the size of the vector (i.e. the fraction of the vector with set bits).

        Note that the expectedFp function returns a more descriptive statistic (i.e. how often you may expect false positives), but the load factor returns a value that is completely independent of the number of hash functions used.

        OUTPUT:
            a number, the number of set bits in the underlying bit vector divided by the total size of the vector
            
        EXAMPLES::
            sage: a = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: a.getLoadFactor()
            0
            
            sage: a.add(4)
            sage: a.getLoadFactor()
            1/4
        """
        return sum([1 for _ in self.bits]) / self.size

    def __copy__(self):
        """
        Returns a shallow copy of self.  Note that the underlying bit vector in the returned copy is simply a reference to the vector in self, so changes to one (i.e. the addition of any new members to the filter) will affect the other.

        OUTPUT:
            a bloom filter, the shallow copy of self
            
        EXAMPLES::
            sage: import copy
            sage: a = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: a.add(4)
            sage: b = copy.copy(a)
            sage: b == a
            True
            
            sage: a.add(5)
            sage: a.add(6)
            sage: b == a
            True
        """
        copy = Bloomfilter(size = self.size,
                           max_fp_rate = self.max_fp_rate,
                           hash_count = self.hash_count)
        copy.bits = self.bits
        return copy

    def __deepcopy__(self, memodict={}):
        """
        Returns a deep copy of self.

        INPUT:
            -memodict -- a dictionary, standard memoization dictionary for faster copying; should be left to the default value of {} when using deepcopy

        OUTPUT:
            a bloom filter, the deep copy of self
            
        EXAMPLES::
            sage: import copy
            sage: a = Bloomfilter(size=8, hash_count=2, max_fp_rate=0.25)
            sage: a.add(4)
            sage: b = copy.deepcopy(a)
            sage: b == a
            True
            
            sage: a.add(5)
            sage: a.add(6)
            sage: b == a
            False
        """
        copy = Bloomfilter(size = self.size,
                           max_fp_rate = self.max_fp_rate,
                           hash_count = self.hash_count)
        for i in self.bits:
            copy.bits.add(i)
        return copy

    def expectedFp(self):
        """
        Returns the expected false-positive rate for membership testing in self. This rate is calculated by ________.  Note that this value is based on the size of the underlying bit vector, the number of set bits, and the number of hash functions used for the filter.  For the pure size of the vector, or number of set bits, see getVectorSize and getLoadFactor.

        OUTPUT:
            a decimal, the expected rate of false positivies for self
        """
        return

        """
    TODO:
        * pickling
        * testing
        * re-hash boolean once FP is exceeded
        * test efficiency in add/contains:
            * add(n) flips the nth bit, update(set) flips all bits
            * 'n in set' tests membership, issuperset(set) checks if all flipped
    Questions:
        * what to do with max-fp?

    Answers:
        * test hash() vs. using murmur (re-hashing hash()) - use __hash__
        * implement subclass specific for a project (override, use murmurs)
        * repr = "Bloomfilter: <some field information"
        * mightContain function (so user can choose)
        * document fact that you can't delete members (they don't exist), sample GOOD uses, sample BAD uses
        * re-hash yes (default), no option
   """
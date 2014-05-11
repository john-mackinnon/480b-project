class Bloomfilter(object):
    """
    A Bloomfilter is a probabilistic data structure used for membership testing.  Objects added to a Bloomfilter are not actually stored in the filter; rather, each added object is hashed several times, and the corresponding bits are set in a bit vector.  When an object is tested for membership, it is hashed by the same hash functions, and the resulting bits are checked in the bit vector.  If all corresponding bits are set, it is said that the element "may" have been added to the filter; if at least one of the bits is not set, however, it is definitely the case that the object is not a member of the filter.  Note that, in this way, a Bloomfilter may return false positives for membership testing, but will never produce false negatives.  That is, a Bloomfilter should be used when it is desirable to know with some degree of certainty that an object "might" be a member, and with absolute certainty that an object is not a member.
    
    Note that, due to the use of a bit vector to represent the underlying data, it is not possible to retrieve the members added to a filter (nor to iterate, remove, etc.).  If retrievability is desired, or if false positives are not tolerated, a user would be better suited using the builtin set type in python.  However, these concessions allow for extremely space efficient storage (linear in the size of the bit vector), as well as fast lookup (linear in the number of hash functions used - regardless of the number of added members).  Bloomfilters are often effectively used as a pre-screening measure, with a traditional set containing all members stored on disk.
    
    Further, note that due to the bit vector representation, intersection, difference, symmetric difference are all meaningless in the context of a Bloomfilter.  As such, only insertion and union operations are the only possible set behaviors, in addition to membership testing.
    """
    def __init__(self, iterable=None, size=100, max_fp_rate=0.25):
        """
        Initializes a Bloomfilter, either as an empty bit vector of the given size, or containing the elements in the given iterable, if one is provided.
        
        INPUT:
            -iterable -- an iterable collection, from which all elements will be initially added to the filter
            -size -- the size of the underlying bit vector to be used for the filter
            -max_fp_rate -- the maximum allowable rate of estimated false positives
        """
        if (iterable != None):
            #TODO: make capacity appropriate to iterable's size and max_fp_rate
            #TODO: try-catch initialization of the Bitset; better to throw a more localized exception than Bitset's
            self.bits = Bitset(iterable, capacity=size)
        else:
            self.bits = Bitset(capacity=size)
        self.max_fp_rate = max_fp_rate
        
    def __repr__(self):
        """
        Returns a string representing self's underlying bit vector. This is potentially a really awful idea.
        """
        return repr(self.bits)
        
    def __eq__(self, other):
        """
        Checks for equality between other and self.  Returns true if and only if other is an instance of Bloomfilter, with the same allowed false positive rate, and the exact same bit vector state as self; otherwise false.
        
        INPUT:
            -other -- a Bloomfilter, to test equality with self
        
        OUTPUT:
            a boolean, indicating equality of self and other
        """
        if isinstance(other, Bloomfilter):
            return (self.bits == other.bits) and 
                   (self.max_fp_rate == other.max_fp_rate)
        else:
            return NotImplemented
        
    def __ne__(self, other):
        """
        Checks for non-equality between other and self.  Returns false if and only if other is an instance of Bloomfilter, with the same allowed false positive rate, and exact same bit vector state as self; otherwise true.
        
        INPUT:
            -other -- a Bloomfilter, to test non-equality with self
            
        OUTPUT:
            a boolean, indicating non-equliaty of self and other
        """
        if isinstance(other, Bloomfilter):
            return (self.bits != other.bits) or
                   (self.max_fp_rate != other.max_fp_rate)
        else:
            return NotImplemented
    
    def __contains__(self, n):
        """
        Tests for possible membership of the object n in self.  Note that "true" only means n is probabilistically a member of self, though this may not be the case; a "false", however, indicates with absolute certainty that n is not a member of self.
        
        INPUT:
            -n -- an object, to test for membership in self
            
        OUTPUT:
            a boolean, indicating if n is possibly a member of self
        """
        return
        
    def add(self, n):
        """
        Inserts element n into self.  Note that n is not retrievable in the future, but, following the insertion, self will always return true when testing n for membership.
        
        INPUT:
            -n -- an object, to add to sel
        """
        return
        
    def union(self, other):
        """
        Returns a new Bloomfliter representing the union of the underlying bit vectors for self, and another Bloomfilter, with the same max false positive rate and capacity as self.  This is semantically equivalent to taking the union of the member sets of the two filters, as any element that is a member of one will also be a member of the resulting Bloomfilter.
        
        INPUT:
            -other -- a Bloomfilter, to union with self
            
        OUTPUT:
            a Bloomfilter, the union of other and self
        """
        return

    def getVectorSize(self):
        """
        Returns the size of the underlying bit vector.
        
        OUTPUT:
            an integer, representing the total number of buckets in self's underlying bit vector
        """
        return self.size
    
    def getLoadFactor(self):
        """
        Returns the load factor of the underlying bit vector.  This is the number of set bits in the vector, divided by the size of the vector (i.e. the fraction of the vector with set bits).
        
        Note that the expectedFp function returns a more descriptive statistic (i.e. how often you may expect false positives), but the load factor returns a value that is completely independent of the number of hash functions used.
        
        OUTPUT:
            a decimal, the number of set bits in the underlying bit vector, divided by the total size of the vector
        """
        return
        
    def __copy__(self):
        """
        Returns a shallow copy of self.  Note that the underlying bit vector in the returned copy is simply a reference to the vector in self, so changes to one will affect the other.
        
        OUTPUT:
            a Bloomfilter, the shallow copy of self
        """
        return
    
    def __deepcopy__(self, memodict={}):
        """
        Returns a deep copy of self. 
       
        INPUT:
            -memodict -- a dictionary, standard memoization dictionary for faster copying; should be left to the default value of {} when using deepcopy
       
        OUTPUT:
            a Bloomfilter, the deep copy of self
        """
        return
        
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
        * BETTER (any?) hash functions
            * number of hash functions
    Questions:
        * membershipTest vs. contains?
        * representation?
   """
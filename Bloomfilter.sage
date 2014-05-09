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
        return
        
    def __ne__(self, other):
        return 
    
    def __contains__(self, n):
        return
        
    def insert(self, n):
        return
        
    def union(self, other):
        return

    def getVectorSize(self):
        return
        
    def __copy__(self):
        return
    
    def __deepcopy__(self, memodict={}):
        return
        
    def expectedFp(self):
        return
    
   """ 
    TODO:
        * pickling
        * testing
    Questions:
        * membershipTest vs. contains?
        * representation?
   """
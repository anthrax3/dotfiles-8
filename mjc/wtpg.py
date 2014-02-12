import sys

class Evaluator:
    def __getattr__(self, name):
        return gdb.parse_and_eval(name)
vals = Evaluator()

def gdbFunction(f):
    class GdbFunction(gdb.Function):
        def __init__(self):
            self.__doc__ = f.__doc__
            super(GdbFunction, self).__init__(f.__name__)

        def invoke(self, *args):
            return f(*args)

    GdbFunction()
    return f

btree_t = gdb.lookup_type('WT_BTREE').pointer()
conn_impl_t = gdb.lookup_type('WT_CONNECTION_IMPL').pointer()

@gdbFunction
def s2bt(s):
    '''Get the btree of a session'''
    return s['dhandle']['handle'].cast(btree_t)

@gdbFunction
def s2c(s):
    '''Get the connection of a session'''
    return s['iface']['connection'].cast(conn_impl_t)

@gdbFunction
def s2cache(s):
    '''Get the cache of a session'''
    return s['iface']['connection'].cast(conn_impl_t)['cache']

@gdbFunction
def bytes_inuse(cache):
    '''Get the bytes in use for a cache'''
    return cache['bytes_inmem'] - cache['bytes_evict']

@gdbFunction
def pgdepth(p):
    '''Get the depth of a page under the root'''
    d = 0
    while p:
        p = p['parent']
        d += 1
    return d

@gdbFunction
def pgup(p, n=1):
    '''Go to an ancestor of a page (default the direct parent)'''
    while p and n:
        p = p['parent']
        n -= 1
    return p

# Use builtin values where possible
try:
    pgtypes = { 
        int(vals.WT_PAGE_INVALID) : "invalid",
        int(vals.WT_PAGE_BLOCK_MANAGER) : "block mgr",
        int(vals.WT_PAGE_COL_FIX) : "leaf fixed",
        int(vals.WT_PAGE_COL_INT) : "int col",
        int(vals.WT_PAGE_COL_VAR) : "leaf var",
        int(vals.WT_PAGE_OVFL) : "overflow",
        int(vals.WT_PAGE_ROW_INT) : "int row",
        int(vals.WT_PAGE_ROW_LEAF) : "leaf row",
    }

    pmflags = {
        int(vals.WT_PM_REC_EMPTY) : "empty",
        int(vals.WT_PM_REC_REPLACE) : "replace",
        int(vals.WT_PM_REC_SPLIT) : "split",
        int(vals.WT_PM_REC_SPLIT_MERGE) : "split-merge",
    }

    refstates = {
        int(vals.WT_REF_DISK) : "disk",
        int(vals.WT_REF_DELETED) : "deleted",
        int(vals.WT_REF_EVICT_FORCE) : "evict force",
        int(vals.WT_REF_EVICT_WALK) : "evict walk",
        int(vals.WT_REF_LOCKED) : "locked",
        int(vals.WT_REF_MEM) : "mem",
        int(vals.WT_REF_READING) : "reading",
    }
except:
    pgtypes = { 
        0 : "invalid",
        1 : "block mgr",
        2 : "leaf fixed",
        3 : "int col",
        4 : "leaf var",
        5 : "overflow",
        6 : "int row",
        7 : "leaf row",
    }

    pmflags = {
        1 : "empty",
        2 : "replace",
        4 : "split",
        8 : "split-merge",
    }

    refstates = {
        0 : "disk",
        1 : "deleted",
        2 : "evict force",
        3 : "evict walk",
        4 : "locked",
        5 : "mem",
        6 : "reading",
    }

@gdbFunction
def pgprint(p, prefix=''):
    '''Pretty print a page'''
    moddesc = ''
    mod = p['modify']
    ref = p['ref']
    if mod:
        flags = int(mod['flags'])
        if flags:
            moddesc = ' (mod %s)' % (', '.join(pmflags[1<<s] for s in range(10) if flags & (1<<s)))
        else:
            moddesc = ' (mod normal)'
    if ref:
            refdesc = ' [ref %s]' % refstates[int(ref['state'])]
    else:
            refdesc = ' [no ref]'
    print('%stype %s, entries %d, footprint %d%s%s' % (prefix, pgtypes[int(p['type'])], p['entries'], p['memory_footprint'], refdesc, moddesc))
    return 0

@gdbFunction
def pgprint_all(p):
    '''Print a page and all ancestors'''
    prefix = ''
    while p:
        pgprint(p, prefix)
        p = p['parent']
        prefix += '^'
    return 0

tchars = { 
    int(vals.WT_PAGE_ROW_INT) : "I",
    int(vals.WT_PAGE_ROW_LEAF) : "L"
}
SPLIT_MERGE = int(vals.WT_PM_REC_SPLIT_MERGE)

REF_DISK = int(vals.WT_REF_DISK)
REF_DELETED = int(vals.WT_REF_DELETED)
REF_READING = int(vals.WT_REF_READING)

def ptype(p):
    mod = p['modify']
    if mod:
        flags = int(mod['flags'])
        if flags & SPLIT_MERGE:
            return "S"
    return tchars[int(p['type'])]

@gdbFunction
def treeprint_int(p, f, indent=1):
    '''Print a picture of a page and all children'''
    c = ptype(p)
    f.write(c)
    have_children = False
    if c != 'L':
        children = p['u']['intl']['t']
        for i in range(int(p['entries'])):
            r = children[i]
            state = int(r['state'])
            if state != REF_DISK and state != REF_DELETED and state != REF_READING:
                if have_children:
                    f.write(' ' * indent)
                have_children = True
                treeprint_int(r['page'], f, indent+1)
    if not have_children:
        f.write('\n')

@gdbFunction
def treeprint(p, fname=None):
    if fname:
        f = open(fname.string(), 'w')
    else:
        f = sys.stdout
    treeprint_int(p, f)
    if fname:
        f.close()
    return 0

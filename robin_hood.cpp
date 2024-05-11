// Place `robin_hood.h` int the same directory
// Then compile with `g++ robin_hood.cpp -I. -fPIC -shared -O3 -o robin_hood.so`

#include "robin_hood.h"
#include <cstdint>

using robinhood_uint64_dict = robin_hood::unordered_map<uint64_t, uint64_t>;

extern "C" void* dict_init();
extern "C" void dict_destruct(robinhood_uint64_dict* d);
extern "C" void dict_clear(robinhood_uint64_dict* d);
extern "C" void dict_setindex(robinhood_uint64_dict* d, uint64_t, uint64_t);
extern "C" uint64_t dict_getindex(robinhood_uint64_dict* d, uint64_t);
extern "C" void dict_delete(robinhood_uint64_dict* d, uint64_t);
extern "C" uint64_t dict_size(robinhood_uint64_dict* d);
extern "C" void dict_rehash(robinhood_uint64_dict* d, uint64_t n);
extern "C" void dict_reserve(robinhood_uint64_dict* d, uint64_t n);

void* dict_init() {
	robinhood_uint64_dict* d = (new robinhood_uint64_dict);
	return static_cast<void*>(d);
}

void dict_destruct(robinhood_uint64_dict* d) {
	delete d;
}

void dict_clear(robinhood_uint64_dict* d) {
	d -> clear();
}

void dict_setindex(robinhood_uint64_dict* d, uint64_t value, uint64_t key) {
	(*d)[key] = value;
}

uint64_t dict_getindex(robinhood_uint64_dict* d, uint64_t key) {
	return (*d)[key];
}

void dict_delete(robinhood_uint64_dict* d, uint64_t key) {
	d -> erase(key);
}

void dict_rehash(robinhood_uint64_dict* d, uint64_t n) {
	d -> rehash(n);
}

void dict_reserve(robinhood_uint64_dict* d, uint64_t n) {
	d -> reserve(n);
}

uint64_t dict_size(robinhood_uint64_dict* d) {
	return d -> size();
}

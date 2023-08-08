
struct servernetadr_t {};

enum AAAA { addd = 0, bddd = 1 };

struct tester {
  const struct servernetadr_t * a;
  struct servernetadr_t *const* b;
  struct servernetadr_t ** c;
  
  struct servernetadr_t * f;
  enum AAAA en;
  char t[133] ;
const void * cvp;
  void* ipt;
  const char * cc;
  const char ** ccc;
};
  void a(const struct servernetadr_t * a);
  void b(struct servernetadr_t *const* b);
  void c(struct servernetadr_t ** c);
  
  void f(struct servernetadr_t * f);

// void ast(const struct servernetadr_t & d);
// void bst(struct servernetadr_t & e)
int k_iSteamNetworkingMessagesCallbacks = 1;
#pragma pack(push)
struct SteamNetworkingMessagesSessionFailed_t
{ 
	enum { k_iCallback =  2 };

	/// Detailed info about the session that failed.
	/// SteamNetConnectionInfo_t::m_identityRemote indicates who this session
	/// was with.
	struct servernetadr_t m_info;
};
#pragma pack(pop)

typedef void (*FnSteamNetworkingMessagesSessionFailed)(struct SteamNetworkingMessagesSessionFailed_t *);

struct SteamNetworkingMessagesSessionFailed_t* SteamAPI_ISteamHTMLSurface_Init(struct SteamNetworkingMessagesSessionFailed_t* self );
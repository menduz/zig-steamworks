const steam = @import("main.zig");

/// If you pass MASTERSERVERUPDATERPORT_USEGAMESOCKETSHARE into usQueryPort, then it causes the game server API to use
/// "GameSocketShare" mode, which means that the game is responsible for sending and receiving UDP packets for the master
/// server updater.
///
/// More info about this here: https://partner.steamgames.com/doc/api/ISteamGameServer#HandleIncomingPacket
pub const MASTERSERVERUPDATERPORT_USEGAMESOCKETSHARE = 0xFFFF;

const gameserver_internal_check_interface_versions =
    "SteamUtils010\x00" ++
    "SteamNetworkingUtils004\x00" ++
    "SteamGameServer015\x00" ++
    "SteamGameServerStats001\x00" ++
    "STEAMHTTP_INTERFACE_VERSION003\x00" ++
    "STEAMINVENTORY_INTERFACE_V003\x00" ++
    "SteamNetworking006\x00" ++
    "SteamNetworkingMessages002\x00" ++
    "SteamNetworkingSockets012\x00" ++
    "STEAMUGC_INTERFACE_VERSION021\x00" ++
    "\x00";

extern fn SteamInternal_GameServer_Init_V2(unIP: steam.uint32, usGamePort: steam.uint16, usQueryPort: steam.uint16, eServerMode: steam.EServerMode, pchVersionString: [*c]const u8, pszInternalCheckInterfaceVersions: [*c]const u8, pOutErrMsg: ?*anyopaque) callconv(.c) c_int;

// Initialize SteamGameServer client and interface objects, and set server properties which may not be changed.
//
// After calling this function, you should set any additional server parameters, and then
// call ISteamGameServer::LogOnAnonymous() or ISteamGameServer::LogOn()
//
// - usLegacySteamPort is the local port used to communicate with the steam servers.
//   NOTE: unless you are using ver old Steam client binaries, this parameter is ignored, and
//         you should pass 0.  Gameservers now always use WebSockets to talk to Steam.
//         This protocol is TCP-based and thus always uses an ephemeral local port.
//         Older steam client binaries used UDP to talk to Steam, and this argument was useful.
//         A future version of the SDK will remove this argument.
// - usGamePort is the port that clients will connect to for gameplay.
// - usQueryPort is the port that will manage server browser related duties and info
//      pings from clients.  If you pass MASTERSERVERUPDATERPORT_USEGAMESOCKETSHARE for usQueryPort, then it
//      will use "GameSocketShare" mode, which means that the game is responsible for sending and receiving
//      UDP packets for the master  server updater. See references to GameSocketShare in isteamgameserver.h.
// - The version string is usually in the form x.x.x.x, and is used by the master server to detect when the
//      server is out of date.  (Only servers with the latest version will be listed.)
pub fn SteamInternal_GameServer_Init(unIP: steam.uint32, usLegacySteamPort: u16, usGamePort: steam.uint16, usQueryPort: steam.uint16, eServerMode: steam.EServerMode, pchVersionString: [*c]const u8) bool {
    _ = usLegacySteamPort;
    return SteamInternal_GameServer_Init_V2(unIP, usGamePort, usQueryPort, eServerMode, pchVersionString, gameserver_internal_check_interface_versions.ptr, null) == 0;
}

// Shutdown SteamGameSeverXxx interfaces, log out, and free resources.
pub extern fn SteamGameServer_Shutdown() callconv(.c) void;

// Most Steam API functions allocate some amount of thread-local memory for
// parameter storage. Calling SteamGameServer_ReleaseCurrentThreadMemory()
// will free all API-related memory associated with the calling thread.
// This memory is released automatically by SteamGameServer_RunCallbacks(),
// so single-threaded servers do not need to explicitly call this function.
// pub extern fn SteamGameServer_ReleaseCurrentThreadMemory() void;

pub extern fn SteamGameServer_BSecure() callconv(.c) bool;
pub extern fn SteamGameServer_GetSteamID() callconv(.c) u64;

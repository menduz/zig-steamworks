const std = @import("std");
const steam = @import("steamworks");
var allocator: std.mem.Allocator = undefined;

/// callback hook for debug text emitted from the Steam API
pub fn SteamAPIDebugTextHook(nSeverity: c_int, pchDebugText: [*c]const u8) callconv(.C) void {
    // if you're running in the debugger, only warnings (nSeverity >= 1) will be sent
    // if you add -debug_steamapi to the command-line, a lot of extra informational messages will also be sent
    std.debug.print("SteamAPIDebugTextHook sev:{} msg: {s}\n", .{ nSeverity, pchDebugText });
}

/// get an authentication ticket for our user
fn authTicket(identity: *steam.SteamNetworkingIdentity) !void {
    const rgchToken: []u8 = try allocator.alloc(u8, 2048);
    var unTokenLen: c_uint = 0;
    const m_hAuthTicket = steam.SteamUser().GetAuthSessionTicket(rgchToken, &unTokenLen, identity);
    std.debug.print("GetAuthSessionTicket={} len={} token={s:0}\n", .{ m_hAuthTicket, unTokenLen, rgchToken });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    allocator = gpa.allocator();

    std.debug.print("Starting\n", .{});
    if (steam.SteamAPI_RestartAppIfNecessary(480)) {
        // if Steam is not running or the game wasn't started through Steam, SteamAPI_RestartAppIfNecessary starts the
        // local Steam client and also launches this game again.

        // Once you get a public Steam AppID assigned for this game, you need to replace k_uAppIdInvalid with it and
        // removed steam_appid.txt from the game depot.
        @panic("SteamAPI_RestartAppIfNecessary");
    }

    if (steam.SteamAPI_Init()) {
        std.debug.print("Steam initialized correctly. \n", .{});
    } else {
        @panic("Steam did not init\n");
    }

    steam.SteamClient().SetWarningMessageHook(SteamAPIDebugTextHook);

    defer steam.SteamAPI_Shutdown();

    std.debug.print("User {?}\n", .{steam.SteamUser().GetSteamID()});

    var sock = steam.SteamNetworkingSockets_SteamAPI();

    var pInfo: *steam.SteamNetworkingFakeIPResult_t = try allocator.create(steam.SteamNetworkingFakeIPResult_t);
    defer allocator.destroy(pInfo);

    sock.GetFakeIP(0, pInfo);
    std.debug.print("GetFakeIP: {}\n", .{pInfo});
    if (!pInfo.m_identity.IsEqualTo(&pInfo.m_identity)) @panic("not equal");

    if (steam.SteamUser().BLoggedOn()) {
        std.debug.print("Current username: {s}\n", .{steam.SteamFriends().GetPersonaName()});
    }

    const pDetails: *steam.SteamNetAuthenticationStatus_t = try allocator.create(steam.SteamNetAuthenticationStatus_t);
    defer allocator.destroy(pDetails);

    const connectionStatus = sock.GetAuthenticationStatus(pDetails);
    std.debug.print("GetAuthenticationStatus: {} {}\n", .{ connectionStatus, pDetails });

    const pIdentity: *steam.SteamNetworkingIdentity align(1) = try allocator.create(steam.SteamNetworkingIdentity);
    allocator.destroy(pIdentity);
    const r = sock.GetIdentity(pIdentity);
    std.debug.print("GetIdentity={} {}\n", .{ r, pIdentity });

    try authTicket(pIdentity);

    var utils = steam.SteamNetworkingUtils_SteamAPI();

    var addr: steam.SteamNetworkingIPAddr = .{
        .m_ipv6 = [_]u8{0} ** 16,
        .m_port = 0,
    };
    var addr2: steam.SteamNetworkingIPAddr = .{
        .m_ipv6 = [_]u8{ 0, 17, 0, 187, 0, 204, 0, 0, 0, 0, 0, 0, 0, 9, 0, 9 },
        .m_port = 0,
    };
    if (!utils.SteamNetworkingIPAddr_ParseString(&addr, "11:bb:cc::9:9")) {
        @panic("ParseString failed");
    }
    std.debug.print("Parsed address: {any}\n", .{addr});
    if (!addr.IsEqualTo(&addr2)) {
        @panic("Addr is equal failed");
    }
}
